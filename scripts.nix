pkgs: [
  (pkgs.writeShellScriptBin "overview" ''
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "Available commands"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  fmt:\n\tFormat Nix files without writing a lock file"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  check:\n\tRun statix and deadnix"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  mend:\n\tAttempt to automatically fix issues found by statix"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  vm-build:\n\tPerform a dry run build"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  vm-test:\n\tTest unattended install"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  update:\n\tFormat and update flake inputs"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  upgrade:\n\tFormat and switch to the new Home Manager configuration"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  rollback:\n\tRollback to a previous generation"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  delete:\n\tDelete previous generations"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  clean:\n\tRemove result symlink and other build artifacts"
  '')

  (pkgs.writeShellScriptBin "remote" ''
    if [ $# -ne 2 ];then
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "Usage:"
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "  install <host> <target>"
      exit 1
    fi

    host=$1
    target=$2

    ${pkgs.nix}/bin/nix run github:nix-community/nixos-anywhere -- \
      --generate-hardware-config nixos-generate-config ./machines/''${host}/hardware-configuration.nix \
      --flake ".#''${host}" "root@''${target}"
  '')

  (pkgs.writeShellScriptBin "fmt" ''
    ${pkgs.nix}/bin/nix fmt --no-write-lock-file
  '')

  (pkgs.writeShellScriptBin "check" ''
    ${pkgs.statix}/bin/statix check -i **/hardware-configuration.nix .
    ${pkgs.deadnix}/bin/deadnix --exclude $(ls machines/*/hardware-configuration.nix) .
    ${pkgs.nix}/bin/nix flake check --no-write-lock-file --all-systems
  '')

  (pkgs.writeShellScriptBin "mend" ''
    ${pkgs.statix}/bin/statix fix -i **/hardware-configuration.nix .
  '')

  (pkgs.writeShellScriptBin "vm-test" ''
    host=$(${pkgs.uutils-coreutils-noprefix}/bin/hostname)
    ${pkgs.nix}/bin/nix build .#nixosConfigurations.''${host}.config.system.build.diskoImagesScript && ./result
  '')

  (pkgs.writeShellScriptBin "vm-build" ''
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build-vm-with-bootloader --flake .
  '')

  (pkgs.writeShellScriptBin "update" ''
    ${pkgs.nix}/bin/nix fmt --no-write-lock-file
    ${pkgs.nix}/bin/nix flake update
  '')

  (pkgs.writeShellScriptBin "upgrade" ''
    if [ $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) -ne 0 ]; then
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "Root privileges required."
      exit 1
    fi

    host=$1

    if [ -z $host ]; then
      host=$(${pkgs.uutils-coreutils-noprefix}/bin/hostname)
    fi

    ${pkgs.uutils-coreutils-noprefix}/bin/echo Running rebuild switch for $host

    ${pkgs.nix}/bin/nix fmt --no-write-lock-file
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#"''${hostname}"
  '')

  (pkgs.writeShellScriptBin "rollback" ''
    if [ $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) -ne 0 ]; then
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "Root privileges required."
      exit 1
    fi

    ${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system
    generation=""
    read -p "Enter number: " generation
    ${pkgs.nix}/bin/nix-env --switch-generation $generation -p /nix/var/nix/profiles/system
  '')

  (pkgs.writeShellScriptBin "delete" ''
    if [ $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) -ne 0 ]; then
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "Root privileges required."
      exit 1
    fi

    ${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system
    generation=""
    read -p "Enter number(s): " generation
    ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations $generation
  '')

  (pkgs.writeShellScriptBin "clean" ''
    ${pkgs.uutils-coreutils-noprefix}/bin/rm -f result
    ${pkgs.nix}/bin/nix-collect-garbage -d
  '')
]
