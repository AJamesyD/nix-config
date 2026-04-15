# TODO(nushell#17803): re-enable checks when nushell SHLVL tests are fixed upstream.
# Disable bat-extras test suite to remove nushell from the dependency closure.
# nushell is only in nativeCheckInputs (shell-detection tests); the runtime
# binaries never reference it. nushell 0.112.1 SHLVL tests fail in the macOS
# Nix sandbox (nushell#17803, 2026-03-14), blocking the entire darwin rebuild.
# overrideScope propagates through the bat-extras package set so all
# subpackages (batman, batdiff, batpipe, etc.) pick up the change.
# Both core and buildBatExtrasPkg carry nushell in nativeCheckInputs;
# disabling checks on both removes it from the entire closure.
final: prev: {
  bat-extras = prev.bat-extras.overrideScope (
    _bfinal: bprev: {
      core = bprev.core.overrideAttrs { doCheck = false; };
      buildBatExtrasPkg = args: (bprev.buildBatExtrasPkg args).overrideAttrs { doCheck = false; };
    }
  );
}
