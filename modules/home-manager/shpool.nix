{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.services.shpool;
  tomlFormat = pkgs.formats.toml { };

  # Copied from https://github.com/nix-community/home-manager/blob/4b6dd06c6a92308c06da5e0e55f2c505237725c9/modules/programs/aerospace.nix#L13-L38
  # filterAttrsRecursive supporting lists, as well.
  filterListAndAttrsRecursive =
    pred: set:
    lib.listToAttrs (
      lib.concatMap (
        name:
        let
          v = set.${name};
        in
        if pred v then
          [
            (lib.nameValuePair name (
              if lib.isAttrs v then
                filterListAndAttrsRecursive pred v
              else if lib.isList v then
                (map (i: if lib.isAttrs i then filterListAndAttrsRecursive pred i else i) (lib.filter pred v))
              else
                v
            ))
          ]
        else
          [ ]
      ) (lib.attrNames set)
    );
  filterNulls = filterListAndAttrsRecursive (v: v != null);
in
{
  options.services.shpool = {
    enable = lib.mkEnableOption "shpool, a service that enables session persistence";
    package = lib.mkPackageOption pkgs "shpool" { };
    settings = lib.mkOption {
      example = {
        prompt_prefix = "[$SHPOOL_SESSION_NAME]";
        session_restore_mode = "simple";
        keybinding = [
          {
            binding = "Ctrl-a d";
            action = "detach";
          }
        ];
        motd = "dump";
      };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/shpool/config.toml`.

        See <https://github.com/shell-pool/shpool/blob/master/CONFIG.md>
        for options.
      '';
      type = lib.types.submodule {
        freeformType = tomlFormat.type;
        options = {
          prompt_prefix = lib.mkOption {
            type = with types; nullOr str;
            default = null;
            description = ''
              By default, shpool will detect when you are using a shell it knows how to inject a prompt into. Currently, those shells include bash, zsh and fish, but more may be added in the future. If it noticed you are using one such shell, it will inject the prompt prefix shpool:$SHPOOL_SESSION_NAME at the beginning of your prompt in order to hint to you when you are inside of a shpool session.

              You can customize this prompt prefix by setting a new value in your config. For example, to show the shpool session name inside square brackets, you can put
            '';
          };
          session_restore_mode = lib.mkOption {
            type =
              with types;
              nullOr (
                either
                  (enum [
                    "screen"
                    "simple"
                  ])
                  (submodule {
                    options = {
                      lines = lib.mkOption {
                        type = ints.positive;
                        description = "Restore the last n lines of history";
                      };
                    };
                  })
              );
            default = null;
            description = "shpool can do a few different things when you re-attach to an existing session. You can choose what you want it to do with the session_restore_mode configuration option";
            example = "simple";
          };
          keybinding = lib.mkOption {
            type =
              with types;
              nullOr (
                listOf (submodule {
                  options = {
                    binding = lib.mkOption {
                      type = str;
                      example = "Ctrl-a d";
                    };
                    # https://github.com/shell-pool/shpool/blob/0e45a86f1875636fe10253815d714970299c5ae7/libshpool/src/daemon/keybindings.rs#L201-L207
                    action = lib.mkOption {
                      type = enum [
                        "detach"
                        "noop"
                      ];
                      description = "Action for shpool keybinding";
                      example = "detach";
                    };
                  };
                })
              );
            description = ''
              You may wish to configure your detach keybinding. By default, shpool will detach from the current user session when you press the sequence Ctrl-Space Ctrl-q (press Ctrl-Space then release it and press Ctrl-q, don't try to hold down all three keys at once)

              For the moment, control is the only modifier key supported, but the keybinding engine is designed to be able to handle more, so if you want a different one, you can file a bug with your feature request.
            '';
            default = null;
          };
          motd = lib.mkOption {
            type =
              with types;
              nullOr (
                either
                  (enum [
                    "never"
                    "dump"
                  ])
                  (submodule {
                    options = {
                      pager.bin = lib.mkOption {
                        type = str;
                        description = ''
                          The pager must accept a file name to display as its first argument
                        '';
                        example = "less";
                      };
                    };
                  })
              );
            default = null;
            description = "shpool has support for displaying the message of the day (the message sshd shows you when you first log into a system). This is most relevant to users in institutional settings where important information gets communicated via the message of the day";
            example = "dump";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = lib.mkIf (cfg.package != null) [ cfg.package ];
      file.".config/shpool/config.toml".source = tomlFormat.generate "config" (filterNulls cfg.settings);
    };

    programs = {
      bash = {
        bashrcExtra = # bash
          ''
            # https://github.com/shell-pool/shpool/blob/0e45a86f1875636fe10253815d714970299c5ae7/libshpool/src/daemon/keybindings.rs#L201-L207
            shopt -a huponexit
          '';
      };
    };

    systemd.user = {
      enable = true;
      services.shpool = {
        Unit = {
          Description = "Shpool - Shell Session Pool";
          Requires = [ "shpool.socket" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.shpool}/bin/shpool daemon";
          KillMode = "mixed";
          TimeoutStopSec = "2s";
          SendSIGHUP = "yes";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      # From https://github.com/shell-pool/shpool/blob/master/systemd/shpool.socket
      sockets.shpool = {
        Unit = {
          description = "Shpool Shell Session Pooler";
        };

        Socket = {
          ListenStream = "%t/shpool/shpool.socket";
          SocketMode = "0600";
        };

        Install = {
          WantedBy = [ "sockets.target" ];
        };
      };
    };
  };
}
