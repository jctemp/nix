{...}: {
  module = {
    core = {
      boot.enable = true;
      networking.enable = true;
      locale.enable = true;
      security.enable = true;
      virtualisation.enable = true;
      users.enable = true;
      
      gnome.enable = false;
      audio.enable = false;
      printing.enable = false;
    };

    applications = {
      development.enable = true; 
      terminal = {
        shell.enable = true;
        zellij.enable = true; 
      };
      
      media.enable = false;
      productivity.enable = false;
      web.enable = false;
    };
  };
}