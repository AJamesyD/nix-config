{
  format = builtins.concatStringsSep "" [
    "$directory"
    "$git_branch"
    "$fill"
    "$status"
    "$cmd_duration"
    "$jobs"
    "$nix_shell"
    "$env_var_SHPOOL_SESSION_NAME"
    "$env_var_ZMX_SESSION"
    "$username"
    "$hostname"
    "\n"
    "$character"
  ];

  character = {
    success_symbol = "[❯](green)";
    error_symbol = "[❯](red)";
  };

  directory = {
    style = "bold cyan";
    truncation_length = 3;
    # Truncate each parent dir to 1 char, but show full name for the last 3
    fish_style_pwd_dir_length = 1;
    # Show path relative to git repo root when inside a repo
    truncate_to_repo = true;
    read_only = " 🔒";
  };

  git_branch = {
    style = "green";
    format = "[$symbol$branch]($style) ";
  };

  git_status.disabled = true;

  fill.symbol = " ";

  status = {
    disabled = false;
    format = "[$symbol$status( \\($signal_name\\))]($style) ";
    symbol = "✘ ";
    style = "red";
    # Show signal names (SIGINT, SIGTERM, etc.)
    map_symbol = true;
  };

  cmd_duration = {
    min_time = 3000;
    style = "yellow";
    format = "[took $duration]($style) ";
  };

  jobs = {
    style = "bold red";
    symbol = "✦";
    format = "[$symbol$number]($style) ";
    number_threshold = 1;
  };

  nix_shell = {
    style = "blue";
    format = "[$symbol$state( \\($name\\))]($style) ";
    symbol = "❄️ ";
  };

  env_var.SHPOOL_SESSION_NAME = {
    style = "bold purple";
    format = "[󰖟 $env_value]($style) ";
  };

  env_var.ZMX_SESSION = {
    style = "bold purple";
    format = "[⚡$env_value]($style) ";
  };

  hostname = {
    ssh_only = true;
    style = "bold yellow";
    format = "[$ssh_symbol$hostname]($style) ";
  };

  username = {
    show_always = false;
    style_user = "yellow";
    format = "[$user@]($style)";
  };

  # Ready to enable: set disabled = false
  direnv.disabled = true;

  aws = {
    disabled = true;
    # When enabled, hide the default profile to reduce noise
    # format = "[$symbol($profile )(\\($region\\) )]($style)";
  };

  kubernetes = {
    disabled = true;
  };
}
