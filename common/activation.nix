{
  config,
  lib,
  pkgs,
  ...
}:
let
  zshcompdir = "${config.programs.zsh.dotDir}/completion/";
in
{
  home = {
    activation = {
      envSetup =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
          ]
          (
            # bash
            ''
              export ZDOTDIR="${config.programs.zsh.dotDir}"
              export ZCOMPDIR="${zshcompdir}"
              mkdir -p $ZCOMPDIR

              export PATH="$PATH:${lib.concatStringsSep ":" config.home.sessionPath}"
              export PATH="$PATH:${config.home.profileDirectory}/bin"
              export PATH="$PATH:/usr/bin"
              export PATH="$PATH:${config.home.homeDirectory}/.toolbox/bin"
            ''
            +
              lib.strings.optionalString pkgs.stdenv.isDarwin # bash
                ''
                  export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
                ''
          );
      mise =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ]
          # bash
          ''
            run --quiet mise prune --yes --quiet
            run --quiet mise plugins update --yes --quiet
          '';
      rustup =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ] # bash
          ''
            run --quiet rustup toolchain install stable --component llvm-tools
            run --quiet rustup toolchain install nightly
            run --quiet rustup update
            run --quiet rustup completions zsh >"$ZCOMPDIR/_rustup"
            run --quiet rustup completions zsh cargo >"$ZCOMPDIR/_cargo"
          '';
    };

    extraActivationPath = with pkgs; [
      curl
      git
      git-lfs
      git-secrets
      gnupg
      gnutar
      gzip
    ];
  };
}
