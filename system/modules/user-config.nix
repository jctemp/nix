{
  config,
  lib,
  userName,
  ...
}: let
  # Default user configuration
  defaultUser = {
    name = userName;
    hashedPassword = "$y$j9T$ED2wTBe5BM1TISOGYdgS11$AkWjWs4kiI0n3kYdlUiuPC33m0aWXV/PK63U7n4Z823";
    keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINi9Ncchcw9R08/jKb6VrgBBvSs78vW9sKUi3Pj5cTiSAAAAEnNzaDphdXRoZW50aWNhdGlvbg== ssh:key-auth-a"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAID8GSpW+Zz1X0UjmiwZbp7vpiHegkxqlMbToJMabBU17AAAAEnNzaDphdXRoZW50aWNhdGlvbg== ssh:key-auth-b"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaKUw7XbzrROfMEWUjohK01FzVNZrMBWtuLvDPCz323H6i9+9Q+KqkcVGyVoaUED8v3X/YGQaPqieugJjAOtech64tbeuYi00iFSaV+sJhJ7/bY+tg1QX46GwieKy4myhvTHFnwDTP6FG73MPomVjErbNOHRb8NueNFYEmGD+XJBrjFFFONTI1/EEdT+TNVG8rg75tYowgCGaKUmUE+rpzi2EcuVbBYCaHFcBvSrwCxf3NwtnxTZJ01z378vzYgKV+atbidsujG/WYSANWiH6h0JPbnbtIRnMVoPibGGVZZMXhasWdC4TuGQMLlPzx9it3n6VthOAIJMMQG3ImBg43lYSQcyv07vWtrfU3DT3QC6DvudLPDDsqRz3R9lVn2nRlc5BRVXgJnolJjensK53a3drtAapCLlCW4njDi/AYcHB2xIFzsgr88gO+fODek0v6v6OG7q9L1EpVY4+UbNbQW8zc/SxQNZ3t2zV1v5aCU+q6G0hj3JPQoCDJCNHsDfrtrP46HO9XUOErK9FYd1Ry4ClMmhK/4fewj8BrGSG8cbL8rfFSVqQQx8s7Bera+z+2yHmLgxvC9a5y3MbeWvRB3PP2gEzc5kku0eDyhBX8DZRm5facML/eHGqZcVwMqeyHph+OxplpbyBpW+Y8ehYpyDPHaMLw85EzvhA/tB80SQ== openpgp:0x4C957822"
    ];
  };

  # Function to check if groups exist
  checkGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  options.modules.users = {
    primaryUser = lib.mkOption {
      type = lib.types.attrs;
      default = defaultUser;
      description = "Primary user configuration";
    };

    enableRootLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable direct root login (not recommended)";
    };
  };
  config = {
    users.users.${config.modules.users.primaryUser.name} = {
      name = config.modules.users.primaryUser.name;
      hashedPassword = config.modules.users.primaryUser.hashedPassword;
      isNormalUser = true;
      openssh.authorizedKeys.keys = config.modules.users.primaryUser.keys;
      extraGroups =
        [
          "wheel" # Enable sudo
        ]
        ++ (checkGroups [
          # Hardware access groups
          "audio"
          "video"

          # Virtualization groups
          "docker"
          "podman"
          "libvirt"

          # Special purpose groups
          "git"
          "networkmanager"

          # Printing and scanning
          "scanner"
          "lp"
        ]);
    };

    # Create SSH directory for the primary user
    systemd.tmpfiles.rules = let
      u = config.users.users.${config.modules.users.primaryUser.name}.name;
      g = config.users.users.${config.modules.users.primaryUser.name}.group;
    in [
      "d /home/${config.modules.users.primaryUser.name}/.ssh 0750 ${u} ${g} -"
      "d /home/${config.modules.users.primaryUser.name}/.ssh/sockets 0750 ${u} ${g} -"
    ];

    # Configure root user
    users.users.root = {
      hashedPassword = lib.mkIf (!config.modules.users.enableRootLogin) null;
      openssh.authorizedKeys.keys = config.users.users.${config.modules.users.primaryUser.name}.openssh.authorizedKeys.keys;
    };

    # Don't allow root login via ssh
    services.openssh.settings = lib.mkIf config.services.openssh.enable {
      PermitRootLogin = lib.mkForce (
        if config.modules.users.enableRootLogin
        then "yes"
        else "no"
      );
    };

    # Set sudo timeout (how long sudo caches credentials)
    security.sudo.extraConfig = ''
      Defaults        timestamp_timeout=15
    '';

    # Allow members of wheel to use sudo without password (optional)
    security.sudo.wheelNeedsPassword = true;
  };
}
