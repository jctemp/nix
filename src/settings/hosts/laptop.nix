{
  # Enable laptop-specific modules
  module = {
    core = {
      gnome.enable = true;
      audio.enable = true;
      printing.enable = true;
      networking = {
        enable = true;
        networkManager.enable = true;
        wireless.enable = true;
      };
      security = {
        enable = true;
        yubikey.enable = true;
      };
      virtualisation = {
        enable = true;
        containers.enable = true;
      };
    };

    applications = {
      development = {
        git.enable = true;
        helix.enable = true;
      };
      media = {
        enable = true;
        categories.modeling.enable = false; # Save space on laptop
      };
      productivity.enable = true;
      terminal = {
        ghostty.enable = true;
        shell.enable = true;
        zellij.enable = true;
      };
      web.enable = true;
    };
  };

  # Laptop-specific hardware
  hardware = {
    # TODO: add nvidia optimus configuration
    nvidia.enable = true;
    bluetooth.enable = true;
    # powerManagement.enable = true; ???
  };

  # TODO: add configuration for laptop
  # Power management for laptop
  # powerManagement = {
  #   enable = true;
  #   powertop.enable = true;
  # };
}
