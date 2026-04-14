# Rustup ships proxy symlinks for every Rust tool, including rust-analyzer.
# When a project's rust-toolchain.toml points to a custom toolchain that lacks
# rust-analyzer (e.g. CargoBrazil), the proxy falls back to the system binary,
# finds itself, and loops. Removing the proxy lets the standalone
# pkgs.rust-analyzer (installed in darwin.nix) win on PATH.
#
# We use symlinkJoin instead of overrideAttrs to avoid recompiling rustup
# from source (the binary cache won't have the modified derivation).
final: prev: {
  rustup = final.symlinkJoin {
    name = "rustup-${prev.rustup.version}";
    paths = [ prev.rustup ];
    postBuild = ''
      rm -f $out/bin/rust-analyzer
    '';
  };
}
