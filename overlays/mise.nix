# mise 2026.6.11: test oci::layer::tests::preserve_metadata_dir_layer_keeps_special_permission_bits
# fails in the Nix sandbox on macOS (setgid bits not preserved).
# Upstream issue likely needed; skip checks until fixed.
final: prev: {
  mise = prev.mise.overrideAttrs (old: {
    doCheck = false;
  });
}
