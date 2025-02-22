{ lib, ... }:
{
  options.hostSpec = {
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host";
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
    safe_path = lib.mkOption {
      type = lib.types.str;
      description = "The base directory for persistence";
      default = "/persist";
    };
    isMinimal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a minimal host";
    };
    modules = {
      virtualisation.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      sshd.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      printing.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      audio.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      bluetooth.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      graphics.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      nvidia.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
