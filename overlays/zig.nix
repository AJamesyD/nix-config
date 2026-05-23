# NOTE: use pre-built zig from ziglang.org via zig-overlay.
#   The official binary statically links LLVM, eliminating ~1.35 GiB of
#   transitive clang-lib + llvm-lib store paths that nixpkgs zig requires.
final: prev: {
  zig = final.zig-overlay."0.14.1";
}
