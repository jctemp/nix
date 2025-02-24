{lib, ...}: {
  options.hostSpec = {
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host";
    };
    system = lib.mkOption {
      type = lib.types.enum [
        "x86_64-linux"
      ];
      description = "Type of loader for system boot";
      default = "x86_64-linux";
    };
    device = lib.mkOption {
      type = lib.types.str;
      description = "Device path for disko";
    };
    loader = lib.mkOption {
      type = lib.types.enum [
        "systemd"
        "grub"
      ];
      description = "Type of loader for system boot";
      default = "systemd";
    };
    safePath = lib.mkOption {
      type = lib.types.str;
      description = "The base directory for persistence";
      default = "/persist";
    };
  };
}
