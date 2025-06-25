{
  config,
  pkgs,
  lib,
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
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra shell packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    users.defaultUserShell = cfg.defaultShell;
    environment.systemPackages = with pkgs; cfg.extraPackages;
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
        # feh = "feh --scale-down --auto-zoom";
        ".." = "cd ..";
      };
    };
  };
}
