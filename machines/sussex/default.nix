{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  module = {
    boot = {
      canTouchEfiVariables = true;
      loader = "systemd";
      device = "";
    };
    multimedia = {
      enable = true;
      bluetoothSupport = true;
    };
    rendering = {
      renderer = true;
      nvidia = true;
      opengl = true;
    };
    privacy = {
      enable = true;
      supportYubikey = true;
    };
    virtualisation = {
      enable = true;
      kubernetes = null;
    };
  };
}
