{
  config,
  lib,
  pkgs,
  ...
}:
let
  keyFile =
    if pkgs.stdenv.isDarwin then
      "/Users/${config.home.username}/.config/sops/age/keys.txt"
    else
      "${config.home.homeDirectory}/.config/sops/age/keys.txt";
in
{
  sops = {
    age.keyFile = keyFile;
    defaultSopsFile = ../secrets/api-keys.yaml;
    secrets.tavily_api_key = { };
    secrets.cachix_auth_token = { };
  };

  programs.zsh.initContent = lib.mkAfter ''
    [ -f "${config.sops.secrets.tavily_api_key.path}" ] && export TAVILY_API_KEY="$(cat "${config.sops.secrets.tavily_api_key.path}")"
    [ -f "${config.sops.secrets.cachix_auth_token.path}" ] && export CACHIX_AUTH_TOKEN="$(cat "${config.sops.secrets.cachix_auth_token.path}")"
  '';
}
