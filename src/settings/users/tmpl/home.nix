{...}: {
  # User-specific module configurations
  module = {
    core = {
      audio.enable = true;
      printing.enable = true;
      virtualisation.enable = true;
      gnome.enable = true;
    };
    
    applications = {
      development = {
        enable = true;
        git = {
          userName = "Jamie Temple";
          userEmail = "jamie.c.temple@gmail.com";
          signing = {
            enable = true;
            key = "6A89175BB28B8B81";
          };
        };
        editor = {
          helix.enable = true;
          vscode.enable = true;
        };
      };

      media = {
        enable = true;
        categories = {
          audio.enable = true;
          video.enable = true;
          graphics.enable = true;
          modeling.enable = true;
        };
      };

      productivity = {
        enable = true;
        categories = {
          notes.enable = false;
          office.enable = false;
          passwords.enable = true;
          research.enable = false;
        };
      };

      terminal = {
        ghostty = {
          enable = true;
          theme = "ayu";
          fontSize = 12;
          maximize = true;
        };
        shell = {
          enable = true;
          prompt = "starship";
          enableDirenv = true;
        };
        zellij = {
          enable = true;
          theme = "ayu_dark";
          simplifiedUi = true;
        };
      };

      web = {
        enable = true;
        browsers.chrome.enable = true;
        defaultBrowser = "chrome";
      };
    };
  };
}
