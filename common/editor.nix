_: {
  editorconfig = {
    enable = true;
    settings = {
      # EditorConfig helps developers define and maintain consistent
      # coding styles between different editors and IDEs
      # EditorConfig is awesome: https://EditorConfig.org

      # python
      "*.{ini,py,py.tpl,rst}" = {
        indent_size = 4;
      };

      # rust
      "*.rs" = {
        indent_size = 4;
      };

      # documentation, utils
      "*.{md,mdx,diff}" = {
        trim_trailing_whitespace = false;
      };

      # windows shell scripts
      "*.{cmd,bat,ps1}" = {
        end_of_line = "crlf";
      };
    };
  };

  xdg.configFile = {
    "markdownlint-cli/.markdownlint-cli2.yaml" = {
      text = # yaml
        ''
          config:
            ul-indent:
              indent: 4
              start_indent: 4
              start_indented: false
            heading-increment: false
            line-length:
              code_block_line_length: 100
              line_length: 250
            blanks-around-headings:
              lines_above: 1
              lines_below: 0
            no-duplicate-heading:
              siblings_only: true
            single-title: false
            blanks-around-fences: false
            blanks-around-lists: false
            no-inline-html: false
            first-line-heading: false

          # Ignore files referenced by .gitignore (only valid at root)
          gitignore: true

          # Disable progress on stdout (only valid at root)
          noProgress: true
        '';
    };
  };
}
