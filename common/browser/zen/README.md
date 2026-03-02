# Zen Browser

Config managed by Nix via
[zen-browser-flake](https://github.com/0xc000022070/zen-browser-flake)
with `package = null` (Homebrew cask manages the binary).

## Files

| File | Purpose |
|---|---|
| `default.nix` | Module: imports zen-browser-flake, configures profile, places files |
| `settings.nix` | `about:config` prefs enforced via `user.js` |
| `extensions.nix` | Extension list (documentation only — not enforced) |

## Common tasks

### Add or change a setting

1. Find the pref name in `about:config`.
2. Add it to `settings.nix`.
3. `darwin-rebuild switch` + restart Zen.

Settings in `user.js` are applied on every browser start. You can
change settings in `about:config` freely — they work immediately but
get overridden on next restart after a rebuild.

### Install an extension

1. Install it in Zen (AMO, drag-drop `.xpi`, etc.).
2. Add its ID and name to `extensions.nix` for documentation.
   Find the ID in `about:debugging#/runtime/this-firefox`.

Extensions are not enforced by Nix — `extensions.nix` is just a
reference for setting up new machines.

### Update keyboard shortcuts

1. Make changes in Zen's keyboard shortcuts UI.
2. Format and commit the updated file:
   ```sh
   cp ~/Library/Application\ Support/zen/Profiles/default/zen-keyboard-shortcuts.json \
      ~/.config/nix/common/browser/zen/
   cd ~/.config/nix && jq '.' common/browser/zen/zen-keyboard-shortcuts.json > tmp.json \
      && mv tmp.json common/browser/zen/zen-keyboard-shortcuts.json
   ```
3. `darwin-rebuild switch`.

### Update handlers (file/protocol associations)

Same process as keyboard shortcuts, but copy `handlers.json` instead.

### Bookmarks

Not managed by Nix. Use Firefox Sync or manual export/import.
