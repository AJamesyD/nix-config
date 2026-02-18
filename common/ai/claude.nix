{ pkgs, ... }:
{
  home = {
    file = {
      ".claude/settings.json" = {
        text = builtins.toJSON {
          model = "opusplan";
          cleanupPeriodDays = 14;
          includeCoAuthoredBy = false;
          permissions = {
            allow = [
              "Bash(git log:*)"
              "Bash(git status:*)"
              "Bash(ls:*)"
              "Bash(npm run lint)"
              "Bash(npm run test:*)"
              "Bash(cargo test:*)"
              "Bash(cargo nextest:*)"
              # GSD permissions
              "Bash(node:*)"
              "Bash(git add:*)"
              "Bash(git commit:*)"
              "Bash(git rev-parse:*)"
              "Bash(git checkout:*)"
              "Bash(git branch:*)"
              "Bash(git diff:*)"
              "Bash(git init:*)"
              "Bash(mkdir:*)"
              "Edit(**/*.md)"
              "Edit(.planning/**)"
              "Glob"
              "Grep"
              "LS"
              "Read(*)"
              "WebFetch"
              "WebSearch"
            ];
            deny = [
              "Read(./.env)"
              "Read(./.env.*)"
              "Read(./build)"
              "Read(./config/credentials.json)"
              "Read(./secrets/**)"
            ];
          };
          hooks = {
            SessionStart = [
              {
                matcher = "startup";
                hooks = [
                  {
                    type = "command";
                    command = "~/.claude/hooks/gsd-session-start.sh";
                  }
                ];
              }
            ];
          };
          statusLine = {
            type = "command";
            command = "~/.claude/hooks/gsd-statusline.sh";
          };
          env = {
            DISABLE_BUG_COMMAND = 1;
            DISABLE_ERROR_REPORTING = 1;
            DISABLE_TELEMETRY = 1;
          };
        };
      };
      ".claude/hooks/gsd-session-start.sh" = {
        executable = true;
        text = # bash
          ''
            #!/bin/bash
            STATE=".planning/STATE.md"
            [ -f "$STATE" ] && cat "$STATE"
          '';
      };
      ".claude/hooks/gsd-statusline.sh" = {
        executable = true;
        text = # bash
          ''
            #!/bin/bash
            STATE=".planning/STATE.md"
            if [ -f "$STATE" ]; then
            	phase=$(grep -m1 "^Current phase:" "$STATE" 2>/dev/null | sed 's/^Current phase: *//')
            	status=$(grep -m1 "^Status:" "$STATE" 2>/dev/null | sed 's/^Status: *//')
            	if [ -n "$phase" ]; then
            		printf "GSD: %s" "$phase"
            		[ -n "$status" ] && printf " (%s)" "$status"
            	else
            		echo "GSD: active"
            	fi
            fi
          '';
      };
    };

    packages = with pkgs; [
      claude-code
    ];
  };
}
