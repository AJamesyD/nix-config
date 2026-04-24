# Work around .NET/ICU crash on macOS 26: the nix-provided ICU 76
# aborts inside icu::Locale::Payload::move during globalization init.
# Invariant mode bypasses ICU entirely; marksman needs no locale support.
#
# Uses symlinkJoin (not overrideAttrs) so the upstream binary is fetched
# from cache.nixos.org. overrideAttrs changes the derivation hash,
# forcing a local .NET source build.
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
