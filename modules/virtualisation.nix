{
  pkgs,
  userName,
  ...
}: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = [pkgs.libguestfs];
  users.users.${userName}.extraGroups = ["docker" "libvirtd"];
}
