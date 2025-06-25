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
      office = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable office suite applications";
      };

      research = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable research and reference applications";
      };

      passwords = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable password management applications";
      };

      notes = lib.mkOption {
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
        lib.optionals cfg.categories.office [
          pkgs.onlyoffice-desktopeditors
        ]
        ++ lib.optionals cfg.categories.research [
          pkgs.zotero
        ]
        ++ lib.optionals cfg.categories.passwords [
          pkgs.keepassxc
        ]
        ++ lib.optionals cfg.categories.notes [
          pkgs.obsidian
        ]
        ++ cfg.packagesWithGUI
      );
  };
}