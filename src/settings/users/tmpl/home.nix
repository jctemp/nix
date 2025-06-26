{...}: {
  # User-specific module configurations
  module = {
    core = {
      audio.enable = true;
      networking.enable = true;
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
          signingKey = "6A89175BB28B8B81";
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
          office.enable = true;
          passwords.enable = true;
          research.enable = false;
        };
      };

      web = {
        enable = true;
        browsers = {
          chrome.enable = true;
          firefox.enable = true;
        };
        defaultBrowser = "chrome";
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
          direnv.enable = true;
        };
        zellij = {
          enable = true;
          theme = "ayu_dark";
          simplifiedUi = true;
        };
      };
    };
  };
}
