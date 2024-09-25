{
  hostType,
  pkgs,
  ...
}:
{
  imports = [
    (if hostType == "nix-darwin" then ./darwin.nix else throw "Unknown hostType '${hostType}' for core")
    ./nix.nix
  ];

  documentation = {
    enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      git
      git-lfs
      neofetch
      neovim
      rsync
      vim
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit hostType;
    };
  };

  programs = {
    zsh.enable = true;
  };
}
