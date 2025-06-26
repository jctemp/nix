{...}: {
  module = {
    core = {
      boot.enable = true;
      gnome.enable = true;
      audio.enable = true;
      printing.enable = true;
      networking.enable = true;
      locale.enable = true;
      security.enable = true;
      virtualisation.enable = true;
      users.enable = true;
    };

    applications = {
      development.enable = true;
      media.enable = true;
      productivity.enable = true;
      terminal = {
        ghostty.enable = true;
        shell.enable = true;
        zellij.enable = true;
      };
      web.enable = true;
    };
  };
}