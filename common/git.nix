{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [ lazyjj ];

  home.sessionVariables = {
    # Default 0 is overly conservative: any parse error triggers fallback to
    # line-oriented diff. Raising to 20 keeps structural diffing active for
    # files with minor syntax issues (common in C/C++, generated code, Nix
    # expressions with unusual patterns). Env var applies to all surfaces
    # (git diff, jj diff, lazygit) since they all invoke difft as a subprocess.
    DFT_PARSE_ERROR_LIMIT = "20";
    # Match the 2-space indent convention used across this nix config.
    DFT_TAB_WIDTH = "2";
    # Explicitly set dark background so difftastic picks brighter colors,
    # regardless of terminal profile detection.
    DFT_BACKGROUND = "dark";
  };

  programs = {
    worktrunk.enable = true;

    delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = false; # conflicts with difftastic.jujutsu.enable on ui.diff-formatter
      options = {
        dark = true;
        # Increase contrast for line diffs
        minus-style = "normal darkred";
        plus-style = "normal darkgreen";
        # Enable n/N keybinds to jump between files in multi-file diffs
        navigate = true;
      };
    };
    difftastic = {
      enable = true;
      # git.enable intentionally omitted (defaults to false). HM enforces mutual
      # exclusion with delta.enableGitIntegration (assertion in programs/git.nix).
      # diff.external is set manually in programs.git.settings below. If future HM
      # relaxes the assertion, switch to git.enable = true and remove the manual
      # diff.external.
      jujutsu.enable = true;
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    git = {
      enable = true;
      settings.user.name = "Aidan De Angelis";
      settings.user.email = lib.mkDefault "aidandeangelis@berkeley.edu";
      lfs = {
        enable = true;
      };
      settings = {
        alias = {
          dag = "log --graph --format='format:%C(yellow)%h%C(reset) %C(blue)\"%an\" <%ae>%C(reset) %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)%n%s' --date-order";
        };
        blame = {
          # Harmless if the file doesn't exist in a given repo
          ignoreRevsFile = ".git-blame-ignore-revs";
        };
        branch = {
          sort = "-committerdate";
        };
        column = {
          ui = "auto";
        };
        commit = {
          verbose = true;
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "dimmed-zebra";
          colorMovedWS = "allow-indentation-change";
          context = 5;
          # Manual wiring: depends on programs.difftastic.enable putting difft on $PATH.
          # Replaces what difftastic.git.enable would set (blocked by HM assertion).
          external = "difft";
          interHunkContext = 3;
          renameLimit = 5000;
          wsErrorHighlight = "all";
        };
        fetch = {
          prune = true;
          pruneTags = true;
        };
        help = {
          autocorrect = "prompt";
        };
        # interactive.diffFilter set by programs.delta (enableGitIntegration)
        init = {
          defaultBranch = lib.mkDefault "main";
        };
        merge = {
          # mkForce: mergiraf HM module sets "diff3"; zdiff3 is a superset that
          # adds common-ancestor context. Safe with mergiraf's merge driver (gets
          # clean files, never reads this setting). Incompatible with `mergiraf solve`
          # (parses conflict markers), but we don't use that workflow.
          conflictStyle = lib.mkForce "zdiff3";
          tool = "nvim";
        };
        pager = {
          # Bypass delta (core.pager) for git diff. Difftastic outputs ANSI-colored
          # side-by-side format that delta would mangle. Coupled to diff.external:
          # remove this override if diff.external = "difft" is removed.
          diff = "less -RFX";
        };
        pull = {
          rebase = true;
        };
        push = {
          autoSetupRemote = true;
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        ssh = {
          variant = "ssh";
        };
        submodule = {
          recurse = true;
        };
        tag = {
          sort = "version:refname";
        };
      };
    };
    jujutsu = {
      enable = true;
      settings = {
        # Diffs use difftastic (ui.diff-formatter set by HM); this covers jj log, jj show
        ui.pager = [
          "delta"
          "--paging=always"
        ];
        # Fallback to line-based diff (bypasses difftastic)
        aliases.linediff = [
          "diff"
          "--tool"
          ":git"
        ];
      };
    };
    lazygit = {
      enable = true;
      settings = {
        gui = {
          mouseEvents = false;
          expandFocusedSidePanel = true;
          nerdFontsVersion = "3";
          showDivergenceFromBaseBranch = "onlyArrow";
          showCommandLog = false;
        };
        git = {
          pagers = [
            {
              externalDiffCommand = "difft --color=always --display=inline";
              pager = "delta --dark --paging=never";
            }
          ];
          mainBranches = [
            "main"
            "mainline"
            "master"
          ];
        };
        update.method = "background";
        os.editPreset = "nvim-remote";
        notARepository = "quit";
        promptToReturnFromSubprocess = false;
      };
      shellWrapperName = "lg";
    };
    gitui = {
      enable = true;
      keyConfig = # ron
        ''
          (
            // Vim-style movement (from vim preset)
            open_help: Some(( code: F(1), modifiers: "")),
            move_left: Some(( code: Char('h'), modifiers: "")),
            move_right: Some(( code: Char('l'), modifiers: "")),
            move_up: Some(( code: Char('k'), modifiers: "")),
            move_down: Some(( code: Char('j'), modifiers: "")),
            popup_up: Some(( code: Char('p'), modifiers: "CONTROL")),
            popup_down: Some(( code: Char('n'), modifiers: "CONTROL")),
            page_up: Some(( code: Char('b'), modifiers: "CONTROL")),
            page_down: Some(( code: Char('f'), modifiers: "CONTROL")),
            home: Some(( code: Char('g'), modifiers: "")),
            end: Some(( code: Char('G'), modifiers: "SHIFT")),
            shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
            shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),

            // Lazygit-compatible: Space to stage (lazygit uses Space, gitui default is Enter)
            stage_unstage_item: Some(( code: Char(' '), modifiers: "")),

            // Lazygit-compatible: P to push, p to pull (gitui default is inverted: p=push, f=pull)
            push: Some(( code: Char('P'), modifiers: "SHIFT")),
            force_push: Some(( code: Char('P'), modifiers: "CONTROL")),
            pull: Some(( code: Char('p'), modifiers: "")),

            // Lazygit-compatible: e to edit file
            edit_file: Some(( code: Char('e'), modifiers: "")),

            // Lazygit-compatible: S to stash (lazygit uses 's' in stash menu)
            stashing_save: Some(( code: Char('S'), modifiers: "SHIFT")),

            // Discard changes: lazygit uses 'd'
            status_reset_item: Some(( code: Char('d'), modifiers: "")),
            diff_reset_lines: Some(( code: Char('d'), modifiers: "")),

            // Abort merge: lazygit uses escape-based flow, map to Shift+A
            abort_merge: Some(( code: Char('A'), modifiers: "SHIFT")),

            // Log: mark commit with Space (matches lazygit's commit selection)
            log_mark_commit: Some(( code: Char(' '), modifiers: "")),

            // Undo commit: lazygit uses 'z', gitui uses Shift+U
            undo_commit: Some(( code: Char('z'), modifiers: "")),
          )
        '';
    };
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
  };
}
