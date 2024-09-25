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
      homeDirectory ? null,
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
      assert homeDirectory != null;
      {
        inherit
          type
          hostPlatform
          homeDirectory
          ;
      }
    else
      throw "unknown host type '${type}'";
in
{
  # TODO: change hostnames
  x86-dev-desk = mkHost {
    type = "home-manager";
    hostPlatform = "x86_64-linux";
    homeDirectory = "/home/angaidan";
  };
  arm-dev-desk = mkHost {
    type = "home-manager";
    hostPlatform = "aarch64-linux";
    homeDirectory = "/home/angaidan";
  };
  "80a99738471f" = mkHost {
    type = "nix-darwin";
    hostPlatform = "aarch64-darwin";
  };
  m3-work-laptop = mkHost {
    type = "nix-darwin";
    hostPlatform = "aarch64-darwin";
  };
}
