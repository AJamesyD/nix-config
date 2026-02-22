let
  hasSuffix =
    suffix: content:
    let
      inherit (builtins) stringLength substring;
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix && substring (lenContent - lenSuffix) lenContent content == suffix;

  mkHost =
    {
      type,
      hostPlatform,
      username ? null,
    }:
    if type == "nix-darwin" then
      assert (hasSuffix "darwin" hostPlatform);
      {
        inherit
          type
          hostPlatform
          ;
      }
    else if type == "home-manager" then
      assert username != null;
      {
        # Assuming all Mac's will use nix-darwin and not home-manager alone
        homeDirectory = "/home/${username}";
        inherit
          type
          hostPlatform
          username
          ;
      }
    else
      throw "unknown host type '${type}'";
in
{
  dellangelis = mkHost {
    type = "home-manager";
    hostPlatform = "x86_64-linux";
    username = "aidandeangelis";
  };
  al2-x86-cdd = mkHost {
    type = "home-manager";
    hostPlatform = "x86_64-linux";
    username = "angaidan";
  };

  m3-work-laptop = mkHost {
    type = "nix-darwin";
    hostPlatform = "aarch64-darwin";
  };
}
