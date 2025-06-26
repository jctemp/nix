{
  inputs,
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.terminal.shell;
in {
  options.module.applications.terminal.shell = {
    prompt = lib.mkOption {
      type = lib.types.enum ["starship" "basic"];
      default = "starship";
      description = "Shell prompt to use";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        system-rebuild = "sudo nixos-rebuild switch";
        home-rebuild = "home-manager switch";

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
      description = "Shell aliases";
    };

    completion.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable shell completion";
    };

    direnv.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable direnv for development environments";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = ''
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL=ignoreboth:erasedups
      '';
      description = "Extra shell configuration";
    };
  };

  config = let 
    starshipToml = "${inputs.self}/src/modules/applications/terminal/shell/starship.toml";
  in lib.mkIf cfg.enable {
    home.packages = 
      [
        pkgs.bat
        pkgs.ripgrep
        pkgs.eza
        pkgs.fd
        pkgs.zoxide
        pkgs.fzf
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    programs.bash = {
      enable = true;
      enableCompletion = cfg.completion.enable;
      shellAliases = cfg.aliases;
      bashrcExtra = cfg.extraConfig;
    };

    programs.nushell = {
      enable = true;
      shellAliases = cfg.aliases;
      # TODO: add more configurations options for nushell and make it optionally
      # a default shell for a user
    };

    programs.starship = lib.mkIf (cfg.prompt == "starship") {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile starshipToml);
    };

    programs.direnv = lib.mkIf cfg.direnv.enable {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      config = {
        warn_timeout = "1h";
        load_dotenv = true;
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = ["--height 40%" "--border"];
    };
  };
}