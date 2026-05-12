{
  config,
  lib,
  ...
}:
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/api-keys.yaml;
    secrets.tavily_api_key = { };
    secrets.cachix_auth_token = { };
  };

  programs.zsh.initContent = lib.mkAfter ''
    [ -f "${config.sops.secrets.tavily_api_key.path}" ] && export TAVILY_API_KEY="$(cat "${config.sops.secrets.tavily_api_key.path}")"
    [ -f "${config.sops.secrets.cachix_auth_token.path}" ] && export CACHIX_AUTH_TOKEN="$(cat "${config.sops.secrets.cachix_auth_token.path}")"
  '';
}
