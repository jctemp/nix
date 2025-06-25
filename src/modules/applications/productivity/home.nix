{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.productivity;
in {
  options.module.applications.productivity = {
    categories = {
      office.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable office suite applications";
      };

      research.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable research and reference applications";
      };

      passwords.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable password management applications";
      };

      notes.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable note-taking applications";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      cfg.packages
      ++ lib.optionals ctx.gui (
        lib.optionals cfg.categories.office.enable [
          pkgs.onlyoffice-desktopeditors
        ]
        ++ lib.optionals cfg.categories.research.enable [
          pkgs.zotero
        ]
        ++ lib.optionals cfg.categories.passwords.enable [
          pkgs.keepassxc
        ]
        ++ lib.optionals cfg.categories.notes.enable [
          pkgs.obsidian
        ]
        ++ cfg.packagesWithGUI
      );
  };
}