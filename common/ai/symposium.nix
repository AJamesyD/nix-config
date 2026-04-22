{ pkgs, ... }:
{
  home.packages = [
    # ACP proxy agent (symposium-acp-agent binary)
    (pkgs.callPackage ../../pkgs/symposium { })
    # CLI tool (cargo-agents binary)
    (pkgs.callPackage ../../pkgs/symposium-cli { })
  ];

  # --- Path: v2.0.1 uses dirs::home_dir() -> ~/.symposium/ ---
  # Source: user_config.rs:default_location() at tag symposium-acp-agent-v2.0.1.
  # Override with SYMPOSIUM_CONFIG_DIR env var.
  # Layout:
  #   ~/.symposium/config/agent.json              -- global agent (nix-managed below)
  #   ~/.symposium/config/<name>-<hash>/config.json -- per-workspace mods (runtime-managed by Symposium, NOT nix)
  #   ~/.symposium/bin/<crate>/<version>/bin/<bin> -- cargo-installed mod binaries (runtime-managed)
  #
  # --- Mods: v2.0.1 only reads builtin_recommendations.toml (compiled in) ---
  # There is no disk-based recommendations.toml in v2.0.1. Ferris is commented out
  # in the built-in recommendations. To enable Ferris, edit the workspace config.json
  # directly (add a mod entry with enabled: true). The \symposium:config ACP command
  # also works from an established session but requires the session to connect first.
  #
  # --- Workspace mod guidance ---
  # Built-in recommendations auto-enable symposium-cargo and symposium-rust-analyzer
  # for Rust workspaces. Both are REDUNDANT: kiro and opencode have native LSP and
  # build tools. Starting a second rust-analyzer instance also wastes resources.
  # In workspace configs, set enabled: false on both (keep them present to suppress
  # the recommendation diff, which triggers interactive config mode that hangs in
  # codecompanion). Source: config_agent/mod.rs and recommendations.rs diff_against().
  #
  # --- Upgrade notes ---
  # The main branch (post-v2.0.1) switched back to dirs::config_dir():
  #   macOS: ~/Library/Application Support/symposium/
  #   Linux: ~/.config/symposium/
  # It also added disk-based recommendations: <config_dir>/config/recommendations.toml
  # and a ModConfig "kind" field. On upgrade:
  #   1. Update this path from .symposium/ to the platform config dir
  #   2. Add a home.file for recommendations.toml with Ferris
  #   3. Migrate or delete old ~/.symposium/ data
  #   4. Verify workspace configs parse (schema may have changed)
  home.file.".symposium/config/agent.json".text = builtins.toJSON {
    agent.local = {
      command = "kiro-cli";
      args = [
        "acp"
        "--agent"
        "nvim"
      ];
    };
  };
}
