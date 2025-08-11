{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.shpool;
in
{
  options.services.shpool = {
    enable = lib.mkEnableOption "shpool, a service that enables session persistence";
    package = lib.mkPackageOption pkgs "shpool" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

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
