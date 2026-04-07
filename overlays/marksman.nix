# Work around .NET/ICU crash on macOS 26: the nix-provided ICU 76
# aborts inside icu::Locale::Payload::move during globalization init.
# Invariant mode bypasses ICU entirely; marksman needs no locale support.
final: prev: {
  marksman = prev.marksman.overrideAttrs (old: {
    makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
      "--set"
      "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT"
      "1"
    ];
  });
}
