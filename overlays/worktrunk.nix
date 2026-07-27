# HACK: disable doCheck until worktrunk sandbox tests are fixed upstream.
#   worktrunk 0.68.0 added process-table probes that panic in the macOS Nix
#   sandbox (seatbelt blocks process-info). Hydra 339330205 fails identically.
#   Remove when: `nix build nixpkgs#worktrunk --dry-run` shows a cache hit on
#   aarch64-darwin (means Hydra built it successfully again).
final: prev: {
  worktrunk = prev.worktrunk.overrideAttrs { doCheck = false; };
}
