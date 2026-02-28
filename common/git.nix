{ lib, ... }:
{
  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
      options = {
        dark = true;
        # Increase contrast for line diffs
        minus-style = "normal darkred";
        plus-style = "normal darkgreen";
      };
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    git = {
      enable = true;
      lfs = {
        enable = true;
      };
      settings = {
        alias = {
          dag = "log --graph --format='format:%C(yellow)%h%C(reset) %C(blue)\"%an\" <%ae>%C(reset) %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)%n%s' --date-order";
        };
        branch = {
          sort = "-committerdate";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          colorMovedWS = "allow-indentation-change";
        };
        init = {
          defaultBranch = lib.mkDefault "main";
        };
        merge = {
          tool = "nvim";
        };
        pull = {
          rebase = true;
        };
        push = {
          autoSetupRemote = true;
        };
        rerere = {
          enabled = true;
        };
        submodule = {
          recurse = true;
        };
      };
    };
    jujutsu = {
      enable = true;
      settings = {
        ui.default-command = "log";
        git = {
          auto-local-bookmark = false;
        };
        revsets.log = "present(trunk()) | mine()";
        template-aliases."format_timestamp(timestamp)" = "timestamp.ago()";
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
        };
        git = {
          pagers = [
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
      };
      shellWrapperName = "lg";
    };
    mergiraf.enable = true;
  };
}
