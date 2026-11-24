# HACK: on darwin, build marksman against the prebuilt (-bin) .NET runtime.
#   Stock nixpkgs uses the source-built runtime_9_0, and Hydra builds that on
#   darwin days after nixpkgs-unstable moves, so CI compiled .NET from source
#   after each bump. With -bin only marksman itself builds locally. Linux keeps
#   the stock package, which cache.nixos.org has in time.
#   Not Homebrew: its formula is deprecated (disabled 2027-11-10) and pulls a
#   second .NET (dotnet@9):
#   https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/m/marksman.rb
#   Remove when: Hydra builds darwin .NET before nixpkgs-unstable advances.
final: prev:
let
  dotnetPkgs = prev.dotnetCorePackages;
  # NOTE: maps the whole set, not just runtime_9_0, so a .NET major bump in
  #   marksman needs no edit here. Attrs with no -bin twin pass through.
  preferBinaryDotnet = prev.lib.mapAttrs (name: pkg: dotnetPkgs."${name}-bin" or pkg) dotnetPkgs;
in
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  marksman = prev.marksman.override { dotnetCorePackages = preferBinaryDotnet; };
}
