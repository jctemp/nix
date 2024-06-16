{pkgs}:
with pkgs; [
  (writeShellScriptBin "check" ''
    deadnix --exclude $(ls machines/*/hardware-configuration.nix)
    statix check -i hardware-configuration.nix
    nix fmt --no-write-lock-file
    nix flake check --no-write-lock-file --all-systems
  '')

  (writeShellScriptBin "update" ''
    nix fmt --no-write-lock-file
    nix flake update
  '')

  (writeShellScriptBin "upgrade" ''
    if [ -z "$1" ]; then
      hostname=$(hostname)
    else
      hostname=$1
    fi
    nix fmt --no-write-lock-file
    sudo nixos-rebuild switch --flake .#"''${hostname}"
  '')

  (writeShellScriptBin "rollback" ''
    if [ $(id -u) -ne 0 ]; then
      echo "Root privileges required."
      exit 1
    fi

    nix-env --list-generations --profile /nix/var/nix/profiles/system
    generation=""
    read -p "Enter number: " generation
    nix-env --switch-generation $generation -p /nix/var/nix/profiles/system
  '')

  (writeShellScriptBin "delete" ''
    if [ $(id -u) -ne 0 ]; then
      echo "Root privileges required."
      exit 1
    fi

    nix-env --list-generations --profile /nix/var/nix/profiles/system
    generation=""
    read -p "Enter number(s): " generation
    nix-env --profile /nix/var/nix/profiles/system --delete-generations $generation
  '')
]
