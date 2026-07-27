# HACK(nushell#17803): disable bat-extras tests to remove nushell from closure.
#   nushell is only in nativeCheckInputs (shell-detection tests); the runtime
#   binaries never reference it. nushell 0.112.1 SHLVL tests fail in the macOS
#   Nix sandbox, blocking the entire darwin rebuild.
#   Remove when: nushell#17803 is fixed and bat-extras returns to cache.nixos.org.
final: prev: {
  bat-extras = prev.bat-extras.overrideScope (
    _bfinal: bprev: {
      core = bprev.core.overrideAttrs { doCheck = false; };
      buildBatExtrasPkg = args: (bprev.buildBatExtrasPkg args).overrideAttrs { doCheck = false; };
    }
  );
}
