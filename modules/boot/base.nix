{
  pkgs,
  lib,
  canTouchEfiVariables ? true,
  zfsSupport ? false,
  ...
}: {
  boot = {
    loader.efi.canTouchEfiVariables = canTouchEfiVariables;
    kernelPackages =
      if zfsSupport
      then lib.mkOverride 1000 pkgs.zfs.latestCompatibleLinuxPackages
      else lib.mkOverride 1000 pkgs.linuxPackages;
    initrd.postDeviceCommands =
      if zfsSupport
      then
        lib.mkAfter ''
          zfs rollback -r rpool/local/root@blank
        ''
      else "";
    supportedFilesystems = lib.mkForce ([
        "btrfs"
        "reiserfs"
        "vfat"
        "f2fs"
        "xfs"
        "ntfs"
        "cifs"
      ]
      ++ (
        if zfsSupport
        then ["zfs"]
        else []
      ));
  };
}
