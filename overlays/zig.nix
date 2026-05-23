# NOTE: use pre-built zig from ziglang.org via zig-overlay.
#   The official binary statically links LLVM, eliminating ~1.35 GiB of
#   transitive clang-lib + llvm-lib store paths that nixpkgs zig requires.
#   zig-overlay renamed its overlay attr from `zig-overlay` to `zigpkgs`
#   in commit d483918 (2025-05).
final: prev: {
  zig = final.zigpkgs."0.14.1";
}
