{
  config,
  lib,
  ...
}: {
  options.modules.hostSpec = {
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host";
    };

    disk = lib.mkOption {
      type = lib.types.str;
      description = "Dsk path for disko, e.g. /dev/sda";
    };

    loader = lib.mkOption {
      type = lib.types.enum ["systemd" "grub"];
      description = "Type of loader for system boot";
      default = "systemd";
    };

    safePath = lib.mkOption {
      type = lib.types.str;
      description = "The base directory for persistence";
      default = "/persist";
    };

    kernelPackage = lib.mkOption {
      type = lib.types.enum ["default" "zen" "hardened" "custom"];
      description = "Which kernel package to use";
      default = "default";
    };
    kernelPackages = lib.mkOption {
      type = lib.types.setType;
      description = "Which kernel package to use";
      default = config.boot.kernelPackages;
    };
  };
}
