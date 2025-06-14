{
  config,
  lib,
  ...
}: let
  cfg = config.module.applications.git;
in {
  options.module.core.git = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git user name";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git user email";
    };

    signing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable commit signing";
      };

      key = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "GPG signing key";
      };
    };

    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Git GUI applications to install";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      inherit (cfg) userName;
      inherit (cfg) userEmail;
      signing = lib.mkIf cfg.signing.enable {
        inherit (cfg.signing) key;
        signByDefault = true;
      };
    };

    programs.gitui = {
      enable = true;
      keyConfig = ''
        (
            move_left: Some(( code: Char('h'), modifiers: "")),
            move_right: Some(( code: Char('l'), modifiers: "")),
            move_up: Some(( code: Char('k'), modifiers: "")),
            move_down: Some(( code: Char('j'), modifiers: "")),
            stash_open: Some(( code: Char('l'), modifiers: "")),
            open_help: Some(( code: F(1), modifiers: "")),
            status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
        )
      '';
    };

    home.packages = cfg.applications;
  };
}
