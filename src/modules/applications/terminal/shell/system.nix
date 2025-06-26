{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.terminal.shell;
in {
  options.module.applications.terminal.shell = {
    defaultShell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bash;
      description = "Default system shell";
    };
  };

  config = lib.mkIf cfg.enable {
    users.defaultUserShell = cfg.defaultShell;
    
    environment.systemPackages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    programs.bash = {
      completion.enable = true;
      shellAliases = {
        # color support
        ls = "ls --color=auto";
        dir = "dir --color=auto";
        vdir = "vdir --color=auto";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";

        # modified commands
        df = "df -h";
        du = "du -h";
        free = "free -h";
        less = "less -i";
        mkdir = "mkdir -pv";
        ping = "ping -c 3";
        ".." = "cd ..";
      };
    };
  };
}