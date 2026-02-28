{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
  ];

  programs = {
    lazydocker = {
      enable = true;
    };
  };
}
