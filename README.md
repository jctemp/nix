# CONFIG-SYSTEM

![Static Badge](https://img.shields.io/badge/NixOS-System-036ffc?style=for-the-badge&logo=NixOS&labelColor=ffffff&color=036ffc)

---

This repository contains the modularised NixOS configuration for managing 
multiple machines with varying hardware requirements. Modules can be enabled
or disabled via options `config.hosts.<module>`, which are defined for each
host separately.

## Overview

- _flake.nix/flake.lock:_ Nix flake files for defining dependencies and ensuring 
  reproducibility.
- _iso.nix:_ Configuration for building a custom NixOS installation ISO.
- _machines/:_ Machine-specific NixOS configurations and hardware settings.
- _modules/:_ Reusable NixOS configuration modules for various functionalities.

## Machines

Each subdirectory within machines represents a distinct machine:

- _machines/[machine-name]/default.nix:_ General system configurations for the 
  specified machine.
- _machines/[machine-name]/hardware-configuration.nix:_ Hardware-specific settings 
  (e.g., graphics drivers, kernel modules).

