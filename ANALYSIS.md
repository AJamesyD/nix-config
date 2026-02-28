# Nix Config Analysis — Application-Based Reorganization

> Generated 2026-02-28. Two-pass analysis: prior art research → concrete plan.

## Pass 1: Prior Art & Best Practices

### lovesegfault/nix-config

Uses nixos-unified with a platform-first split:

```
configurations/{nixos,darwin,home}/   # host-specific
modules/{nixos,darwin,home,shared}/   # reusable modules
overlays/
secrets/
```

Groups by **platform**, not application. Modules are exposed as flake outputs
(`nixosModules.*`, `homeModules.*`). Good for multi-machine fleets, but doesn't
solve the "where is my git config?" problem — you still grep across modules.

### Misterio77/nix-config (~1.2k stars)

Hybrid user/host approach:

```
home/<user>/              # per-user HM configs
  features/               # ← the interesting part
    cli/                  # shell tools, grouped by domain
    desktop/              # GUI apps
    productivity/         # notes, email
hosts/                    # host configs
modules/                  # custom NixOS/HM modules
```

The `features/` pattern is the closest to application-based grouping in the
wild. Each feature is a self-contained module that bundles its program config,
packages, and settings. Hosts compose features via imports.

### "Anatomy of a NixOS Config" (unmovedcentre.com)

Recommends a **core/optional** split:

```
common/
  core/       # on ALL hosts — no exceptions
  optional/   # opt-in per host
```

Core modules use `mkDefault` liberally so optional modules and hosts can
override. This is orthogonal to application grouping but complementary — you can
have `core/git.nix` and `optional/containers.nix`.

### nix-starter-configs (community template)

```
modules/{nixos,home-manager}/
```

Minimal, platform-first. No opinion on application grouping.

### Patterns observed

| Pattern | Who | Pros | Cons |
|---|---|---|---|
| **Platform-first** (`modules/{nixos,darwin,home}/`) | lovesegfault, starter-configs | Clear platform boundaries | App config scattered |
| **Concern-first** (`packages.nix`, `programs.nix`, `session.nix`) | Current config (post-Phase 1) | Easy to find "all packages" | App config scattered |
| **Application-domain** (`features/cli/`, `features/desktop/`) | Misterio77 | Complete app context in one place | Cross-cutting concerns need a home |
| **Per-app files** (`programs/git.nix`, `programs/tmux/`) | Various smaller configs | Maximum granularity | Too many tiny files, import noise |

### Key takeaway

The community trend is toward **domain-based grouping** — not one file per app
(too granular), but one file per *application domain* (git ecosystem, shell
ecosystem, editor ecosystem). Each domain module owns its programs, packages,
activation scripts, and session variables. Cross-cutting concerns (XDG, base
PATH) stay in a thin shared module.

This is exactly what `git.nix`, `shell/`, `tmux/`, and `zellij/` already do.
The problem is that `programs.nix`, `packages.nix`, `activation.nix`, and
`session.nix` are concern-based grab-bags that break the pattern.

---

## Pass 2: Reorganization Plan

### Current state

After the Phase 1 refactor, `common/dev.nix` is a barrel importing:

```
dev.nix → activation.nix    # 3 activation scripts (envSetup, mise, rustup)
        → ai/               # claude-code, mise node packages         ✓ well-scoped
        → editor.nix         # editorconfig + markdownlint             ✗ too narrow
        → git.nix            # git + jj + lazygit + delta + mergiraf   ✓ well-scoped
        → languages.nix      # go, java, mise, uv                     ✗ missing rustup, zig, activation
        → packages.nix       # ~50 packages, no grouping              ✗ grab-bag
        → programs.nix       # ~20 program configs, no grouping       ✗ grab-bag
        → session.nix        # sessionVars for many domains + XDG     ✗ grab-bag
        → shell/             # zsh config                              ✓ well-scoped
        → tmux/              # tmux config                             ✓ well-scoped
        → zellij/            # zellij config                           ✓ well-scoped
```

Five modules are well-scoped by application domain. Four are concern-based
grab-bags. The plan dissolves the four grab-bags into domain modules.

### Target structure

```
common/
├── dev.nix                    # barrel: imports everything below
│
│   ── Application domains ──
├── shell/
│   └── default.nix            # zsh + atuin + dircolors + direnv + direnv-instant
│                              #   + fzf + navi + zoxide + fish + nix-your-shell
│                              #   + envSetup activation + .zshrc guard
├── git.nix                    # git + jj + lazygit + lazyjj + delta + mergiraf + gh
├── editor/
│   └── default.nix            # neovim + treesitter + luajit + ast-grep + editorconfig
│                              #   + markdownlint + bat + bacon
│                              #   + linters: ruff, shellcheck, shfmt, stylua
│                              #   + doc tools: mermaid-cli, graphviz, pandoc, pylatexenc
├── languages/
│   └── default.nix            # go + java + mise + uv + rustup + cargo-binstall + zig + mdbook
│                              #   + rustup/mise activation scripts
│                              #   + GOPROXY, MISE_*, BACON_PREFS session vars
├── containers.nix             # docker + docker-compose + lazydocker + orbstack (host)
├── cli.nix                    # "unix toolbox" — tools with no/minimal config:
│                              #   coreutils, curl, wget, fd, ripgrep, eza, jq, less,
│                              #   lesspipe, btop, htop, dust, dua, hyperfine, tealdeer,
│                              #   yazi, gnugrep, gnused, gnutar, gnutls, ncurses,
│                              #   netcat-gnu, rsync, squashfsTools, parallel, libnotify,
│                              #   gnupg, findutils, gawk, bins package
│                              #   + BAT_THEME, LESSHISTFILE session vars
│                              #   + program configs: btop, eza, fd, htop, jq, less,
│                              #     lesspipe, ripgrep, tealdeer, yazi
├── tmux/                      # (unchanged)
├── zellij/                    # (unchanged)
├── ai/                        # (unchanged)
│
│   ── Cross-cutting ──
├── session.nix                # thin: EDITOR + xdg.enable + preferXdgDirectories
│
│   ── Platform / identity (not in barrel) ──
├── aws.nix                    # (unchanged — imported by work hosts directly)
├── darwin.nix                 # (unchanged — imported by darwin hosts)
├── nix-sys.nix                # (unchanged — imported by darwin.nix)
└── nix-common.nix             # (unchanged — imported by hosts for nix.gc + nix.settings)
```

### What moves where

#### `programs.nix` → dissolved

| Program | Destination | Rationale |
|---|---|---|
| atuin | shell/ | Shell history |
| bacon | editor/ | Rust diagnostics viewer (bacon-ls in neovim) |
| bat + bat-extras | editor/ | Code viewer with syntax highlighting |
| btop | cli.nix | System monitor, minimal config |
| dircolors | shell/ | Shell appearance |
| direnv + direnv-instant | shell/ | Directory environment, shell integration |
| eza | cli.nix | ls replacement, minimal config |
| fd | cli.nix | find replacement, minimal config |
| fish | shell/ | Shell (even if just for fish_indent) |
| fzf | shell/ | Deeply shell-integrated fuzzy finder |
| htop | cli.nix | System monitor, no config |
| jq | cli.nix | JSON tool, no config |
| lazydocker | containers.nix | Container management |
| less, lesspipe | cli.nix | Pager |
| navi | shell/ | Shell cheatsheets |
| ripgrep | cli.nix | grep replacement, minimal config |
| tealdeer | cli.nix | tldr pages |
| yazi | cli.nix | File manager |
| zoxide | shell/ | Smart cd, shell integration |

#### `packages.nix` → dissolved

| Package(s) | Destination | Rationale |
|---|---|---|
| bins, coreutils, curl, findutils, gawk, gnugrep, gnupg, gnused, gnutar, gnutls, ncurses, netcat-gnu, rsync, squashfsTools, wget, parallel, libnotify | cli.nix | Core unix tools |
| neovim, tree-sitter, luajit (+packages), ast-grep, markdownlint-cli2 | editor/ | Editor ecosystem |
| mermaid-cli, pylatexenc, graphviz, pandoc | editor/ | Doc generation (used from editor) |
| ruff, shellcheck, shfmt, stylua | editor/ | Linters/formatters (treefmt + neovim LSP) |
| cargo-binstall, rustup, mdbook, zig, usage | languages/ | Language toolchains |
| cachix, devenv, nix-output-monitor, nix-update, nix-your-shell, nixd, nixfmt | shell/ or cli.nix | Nix tools — shell/ gets nix-your-shell, rest go to cli.nix |
| docker, docker-compose | containers.nix | Container runtime |
| lazyjj | git.nix | Jujutsu TUI |
| dust, dua, hyperfine | cli.nix | Disk/benchmark tools |
| git, git-lfs | cli.nix | Base git binary (program config stays in git.nix) |

#### `activation.nix` → dissolved

| Script | Destination | Rationale |
|---|---|---|
| envSetup | shell/ | Sets up ZDOTDIR, ZCOMPDIR, PATH — shell bootstrap |
| mise | languages/ | Mise prune/update — language toolchain maintenance |
| rustup | languages/ | Rustup install/update — language toolchain maintenance |
| extraActivationPath | languages/ | Used by activation scripts above |

#### `session.nix` → distributed

| Variable | Destination | Rationale |
|---|---|---|
| EDITOR | session.nix (stays) | Global |
| LESSHISTFILE | cli.nix | less-specific |
| BACON_PREFS | languages/ | bacon/Rust-specific |
| BAT_THEME | cli.nix | bat-specific (also used by delta, but delta reads it at runtime) |
| GOPROXY | languages/ | Go-specific |
| MISE_* (3 vars) | languages/ | mise-specific |
| xdg.enable | session.nix (stays) | Global |
| preferXdgDirectories | session.nix (stays) | Global |
| .zshrc guard | shell/ | zsh-specific |

### Files deleted

- `common/packages.nix` — contents distributed
- `common/programs.nix` — contents distributed
- `common/activation.nix` — contents distributed

### Files unchanged

- `common/aws.nix` — already well-scoped
- `common/tmux/` — already well-scoped
- `common/zellij/` — already well-scoped
- `common/ai/` — already well-scoped
- `common/darwin.nix` — platform config, not HM
- `common/nix-sys.nix` — darwin-only nix daemon
- `common/nix-common.nix` — shared nix settings (imported by hosts, not barrel)

### Barrel file after reorganization

```nix
# common/dev.nix
{ inputs, ... }:
{
  imports = [
    ./ai
    ./cli.nix
    ./containers.nix
    ./editor
    ./git.nix
    ./languages
    ./session.nix
    ./shell
    ./tmux
    ./zellij
  ];
}
```

### Migration notes

- **No behavior change.** Every option, package, and activation script lands in
  the same place — just a different file. Hosts don't change their imports.
- **direnv-instant** import moves from `dev.nix` barrel to `shell/default.nix`
  (it's a direnv/shell concern).
- **`git.nix`** stays a file (not a directory) — it's already well-scoped and
  adding `lazyjj` doesn't justify a directory.
- **`editor/`** becomes a directory because it'll be large enough to warrant
  splitting later (neovim config, LSP setup, etc.).
- **`languages/`** becomes a directory because it has activation scripts that
  benefit from colocation.
- **`containers.nix`** stays a file — small and unlikely to grow.
- **`cli.nix`** is the new "everything else" — but unlike `packages.nix`, it
  only contains tools with no/minimal config. If a tool grows significant
  config, it graduates to its own domain module.

### Graduation rule

> If a tool in `cli.nix` accumulates more than ~15 lines of config (program
> settings, activation scripts, session vars), it should graduate to its own
> domain module or join an existing one.

### Status: ✅ COMPLETED (2026-02-28)

All three hosts evaluate successfully after the reorganization:
- `m3-work-laptop` (darwin) ✓
- `al2-x86-cdd` (home-manager) ✓
- `dellangelis` (home-manager) ✓

Open questions resolved:
1. **Nix tools** → `cli.nix` (zero config, simplicity wins)
2. **`bat`** → `editor/` (bat-extras and theme are the substantial config)
3. **`shellcheck`/`shfmt`** → `editor/` (used via treefmt and neovim, not interactively)
