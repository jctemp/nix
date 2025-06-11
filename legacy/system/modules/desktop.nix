{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define desktop module options
  options.modules.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktop environment";
    };

    environment = lib.mkOption {
      type = lib.types.enum ["gnome"];
      default = "gnome";
      description = "Desktop environment to use";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to install for desktop use";
    };
  };

  # Implement desktop configurations
  config = lib.mkIf config.modules.desktop.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs;
        [
          libreoffice
          nautilus
          vlc
          gimp
          pavucontrol
        ]
        ++ config.modules.desktop.extraPackages;
    }

    # Font configuration
    {
      fonts.packages = with pkgs; [
        dejavu_fonts
        noto-fonts
        noto-fonts-emoji
        (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})
      ];
    }
  ]);
}
