# HACK(nixpkgs#512070): bypass ICU crash on macOS 26.
#   .NET loads both Nix-provided ICU 76 and Apple's libicucore into the same
#   process; incompatible internal structures cause SIGABRT in icu::Locale.
#   Invariant mode bypasses ICU entirely; marksman needs no locale support.
#   Uses symlinkJoin (not overrideAttrs) to preserve the cache.nixos.org hit.
#   Remove when: nixpkgs#512070 is closed.
final: prev: {
  marksman = final.symlinkJoin {
    name = "marksman-${prev.marksman.version}";
    paths = [ prev.marksman ];
    nativeBuildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/marksman \
        --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
    '';
  };
}
