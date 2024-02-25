# CONFIG-SYSTEM

![Static Badge](https://img.shields.io/badge/NixOS-System-036ffc?style=for-the-badge&logo=NixOS&labelColor=ffffff&color=036ffc)

---

This repository contains the modularised NixOS configuration for managing 
multiple machines with varying hardware requirements. Modules can be enabled
or disabled via options `config.hosts.<module>`, which are defined for each
host separately.

## Overview

- *flake.nix/flake.lock:* Nix flake files for defining dependencies and ensuring 
  reproducibility.
- *iso.nix:* Configuration for building a custom NixOS installation ISO.
- *machines/:* Machine-specific NixOS configurations and hardware settings.
- *modules/:* Reusable NixOS configuration modules for various functionalities.

## Machines

Each subdirectory within machines represents a distinct machine:

- machines/[machine-name]/default.nix: General system configurations for the 
  specified machine.
- machines/[machine-name]/hardware-configuration.nix: Hardware-specific settings 
  (e.g., graphics drivers, kernel modules).

