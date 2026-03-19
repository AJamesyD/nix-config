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
        interactive = {
          diffFilter = "delta --color-only";
        };
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
            }
            {
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
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
  };
}
