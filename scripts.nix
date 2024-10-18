pkgs: [
  (pkgs.writeShellScriptBin "overview" ''
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "Available commands"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  fmt:\n\tFormat Nix files without writing a lock file"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  check:\n\tRun statix and deadnix"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  mend:\n\tAttempt to automatically fix issues found by statix"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  test:\n\tPerform a dry run build"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  update:\n\tFormat and update flake inputs"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  upgrade:\n\tFormat and switch to the new Home Manager configuration"
    ${pkgs.uutils-coreutils-noprefix}/bin/echo -e "  clean:\n\tRemove result symlink and other build artifacts"
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

  (pkgs.writeShellScriptBin "test" ''
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild build-vm-with-bootloader --flake .
  '')

  (pkgs.writeShellScriptBin "update" ''
    ${pkgs.nix}/bin/nix fmt --no-write-lock-file
    ${pkgs.nix}/bin/nix flake update
  '')

  (pkgs.writeShellScriptBin "upgrade" ''
    if [ $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) -ne 0 ]; then
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "Root privileges required."
      ${pkgs.uutils-coreutils-noprefix}/bin/exit 1
    fi

    local host=$1

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
      ${pkgs.uutils-coreutils-noprefix}/bin/exit 1
    fi

    ${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system
    generation=""
    ${pkgs.uutils-coreutils-noprefix}/bin/read -p "Enter number: " generation
    ${pkgs.nix}/bin/nix-env --switch-generation $generation -p /nix/var/nix/profiles/system
  '')

  (pkgs.writeShellScriptBin "delete" ''
    if [ $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) -ne 0 ]; then
      ${pkgs.uutils-coreutils-noprefix}/bin/echo "Root privileges required."
      ${pkgs.uutils-coreutils-noprefix}/bin/exit 1
    fi

    ${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system
    generation=""
    ${pkgs.uutils-coreutils-noprefix}/bin/read -p "Enter number(s): " generation
    ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations $generation
  '')

  (pkgs.writeShellScriptBin "clean" ''
    ${pkgs.uutils-coreutils-noprefix}/bin/rm -f result
    ${pkgs.nix}/bin/nix-collect-garbage -d
  '')
]
