# NOTE: two independent HACKs below; each has its own `Remove when:`.
#
# HACK: bypass an ICU crash on macOS 26.
#   https://github.com/NixOS/nixpkgs/issues/512070
#   .NET loads both Nix-provided ICU and Apple's libicucore into the same
#   process; incompatible internal structures cause SIGABRT in icu::Locale.
#   Invariant mode bypasses ICU entirely; marksman needs no locale support.
#   Uses symlinkJoin (not overrideAttrs) so marksman itself is not rebuilt.
#   Remove when: the issue above is closed.
#
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

  unwrapped =
    if prev.stdenv.hostPlatform.isDarwin then
      prev.marksman.override { dotnetCorePackages = preferBinaryDotnet; }
    else
      prev.marksman;
in
{
  marksman = final.symlinkJoin {
    name = "marksman-${unwrapped.version}";
    paths = [ unwrapped ];
    inherit (unwrapped) version meta;
    nativeBuildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/marksman \
        --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
    '';
  };
}
