{
  config,
  lib,
  pkgs,
  ...
}: let
  isMinimal = config.hostSpec.isMinimal;
in
  lib.mkMerge [
    {
      nix = {
        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
        settings = {
          # See https://jackson.dev/post/nix-reasonable-defaults/
          connect-timeout = 5;
          log-lines = 25;
          min-free = 128000000; # 128MB
          max-free = 1000000000; # 1GB

          experimental-features = "nix-command flakes";
          auto-optimise-store = true;
          keep-outputs = true;
          trusted-users = ["@wheel"];
        };
      };

      # NETWORKING (group = networkmanager)
      networking = {
        hostName = config.hostSpec.hostName;
        hostId = builtins.substring 0 8 (builtins.hashString "md5" config.hostSpec.hostName);
        networkmanager.enable = true;
        firewall.enable = true;
        wireless.enable = false;
      };

      time = {
        timeZone = "Europe/Berlin";
        hardwareClockInLocalTime = true;
      };

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = let
          extraLocale = "de_DE.UTF-8";
        in {
          LC_ADDRESS = extraLocale;
          LC_IDENTIFICATION = extraLocale;
          LC_MEASUREMENT = extraLocale;
          LC_MONETARY = extraLocale;
          LC_NAME = extraLocale;
          LC_NUMERIC = extraLocale;
          LC_PAPER = extraLocale;
          LC_TELEPHONE = extraLocale;
          LC_TIME = extraLocale;
        };
      };

      environment.systemPackages = [
        pkgs.curl
        pkgs.git
        pkgs.tree
        pkgs.wget
        pkgs.vim
      ];
    }

    {
      environment.systemPackages = [
        pkgs.gnupg

        pkgs.yubioath-flutter
        pkgs.yubikey-manager
        pkgs.yubikey-personalization
        pkgs.pcsctools

        (pkgs.writeShellScriptBin "reset-gpg-yubikey" ''
          ${pkgs.gnupg}/bin/gpg-connect-agent "scd serialno" "learn --force" /bye
        '')
      ];

      programs = {
        # Filesystem in Userspace; secure method for non privileged users to
        # create and mount their own filesystem
        fuse.userAllowOther = true;
        gnupg.agent = {
          enable = true;
          pinentryPackage = pkgs.pinentry-curses;
          enableSSHSupport = true;
          settings = {
            default-cache-ttl = 60;
            max-cache-ttl = 120;
          };
        };
        yubikey-touch-detector.enable = true;
      };

      services = {
        udev.packages = [pkgs.yubikey-personalization];
        pcscd.enable = true;
      };

      security.polkit = {
        enable = true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.debian.pcsc-lite.access_card" &&
              subject.isInGroup("wheel")) {
                return polkit.Result.YES;
              }
          });
          polkit.addRule(function(action, subject) {
            if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
              subject.isInGroup("wheel")) {
                return polkit.Result.YES;
              }
          });
        '';
      };
    }

    # =========================================================================
    #                                OPTIONALS

    {
      #
      # FONTS
      #
      fonts.packages = lib.mkIf (!isMinimal) [
        pkgs.dejavu_fonts
        pkgs.cm_unicode
        pkgs.libertine
        pkgs.roboto
        pkgs.noto-fonts
        pkgs.nerdfonts
      ];
    }

    (
      let
        enablePrinting = config.hostSpec.modules.printing.enable;
        enable = enablePrinting && !isMinimal;
      in {
        #
        # PRINTING (group = scanner + lp)
        #
        services.avahi = lib.mkIf enable {
          enable = true;
          nssmdns4 = true;
          openFirewall = true; # required for UDP 5353
          publish = {
            enable = true;
            userServices = true;
          };
        };

        services.printing = lib.mkIf enable {
          enable = true;
          drivers = [
            pkgs.gutenprint
            pkgs.epson-escpr
            pkgs.epson-escpr2
          ];
          browsing = true;
          browsedConf = ''
            BrowseDNSSDSubTypes _cups,_print
            BrowseLocalProtocols all
            BrowseRemoteProtocols all
            CreateIPPPrinterQueues All
            BrowseProtocols all
          '';
        };
      }
    )

    (
      let
        enableAudio = config.hostSpec.modules.audio.enable;
        enable = enableAudio && !isMinimal;
      in {
        #
        # AUDIO (group = audio)
        #
        security.rtkit.enable = enable;
        services.pipewire = lib.mkIf enable {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
          jack.enable = true;
        };
      }
    )

    (
      let
        enableBluetooth = config.hostSpec.modules.bluetooth.enable;
        enable = enableBluetooth && !isMinimal;
      in {
        #
        # BLUETOOTH
        #
        hardware.bluetooth = lib.mkIf enable {
          enable = enableBluetooth && !isMinimal;
          powerOnBoot = true;
          settings = {
            General = {
              Enable = "Source,Sink,Media,Socket";
            };
          };
        };
        services.blueman.enable = enable;
      }
    )

    (
      let
        enableVirtualisation = config.hostSpec.modules.virtualisation.enable;
        enable = enableVirtualisation && !isMinimal;
      in {
        #
        # DOCKER (group = docker)
        #
        virtualisation.containers.enable = enable;
        virtualisation.docker = lib.mkIf enable {
          enable = true;
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };

        #
        # LIBVIRT (group = libvirtd)
        #
        virtualisation.libvirtd.enable = enable;
        programs.virt-manager.enable = enable;

        environment.systemPackages = lib.mkIf enable [
          pkgs.dive
          pkgs.libguestfs
        ];
      }
    )

    (
      let
        enableGraphics = config.hostSpec.modules.graphics.enable;
        enable = enableGraphics && !isMinimal;
      in {
        #
        # GNOME (group = video)
        #
        programs.dconf.enable = enable;
        services.xserver = lib.mkIf enable {
          enable = true;
          displayManager.gdm = {
            enable = true;
            wayland = true;
          };
          desktopManager.gnome.enable = true;
        };

        #
        # OPENGL
        #
        hardware.graphics = lib.mkIf enable {
          enable = true;
          enable32Bit = true;
        };

        environment.systemPackages = lib.mkIf enable [
          pkgs.gnomeExtensions.forge
        ];
      }
    )

    (
      let
        enableGraphics = config.hostSpec.modules.graphics.enable;
        enableNvidia = config.hostSpec.modules.nvidia.enable;
        enable = enableNvidia;
      in {
        #
        # NVIDIA
        #
        nixpkgs.config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "nvidia-x11"
            "nvidia-settings"
          ];

        hardware.nvidia = lib.mkIf enable {
          open = false;
          modesetting.enable = true;
          nvidiaSettings = true;
        };
        services.xserver.videoDrivers = lib.mkIf enable ["nvidia"];

        hardware.nvidia-container-toolkit = lib.mkIf enable {
          enable = true;
          mount-nvidia-executables = true;
        };

        hardware.graphics.extraPackages = lib.mkIf (enable && enableGraphics) [
          pkgs.nvidia-vaapi-driver
        ];
      }
    )

    (
      let
        enableSshd = config.hostSpec.modules.sshd.enable;
        safe_path = config.hostSpec.safe_path;
        enable = enableSshd;
      in {
        #
        # SSHD
        #
        services.openssh = lib.mkIf enable {
          enable = true;
          openFirewall = true;
          settings = {
            KbdInteractiveAuthentication = false;
            PasswordAuthentication = false;
            PermitRootLogin = "no";
            X11Forwarding = false;
          };
          hostKeys = [
            {
              path = "${safe_path}/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
            {
              path = "${safe_path}/ssh/ssh_host_rsa_key";
              type = "rsa";
              bits = 4096;
            }
          ];
        };
      }
    )
  ]
