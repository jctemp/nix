# CONFIG-SYSTEM

![Static Badge](https://img.shields.io/badge/NixOS-System-036ffc?style=for-the-badge&logo=NixOS&labelColor=ffffff&color=036ffc)

## Overview

This repository contains NixOS configurations for multiple systems:

- **desktop**: Full desktop configuration with GNOME
- **laptop**: Laptop configuration with Microsoft Surface optimizations
- **vm**: Minimal VM configuration 
- **wsl**: Windows Subsystem for Linux configuration

## Structure

- `flake.nix`: Entry point for the configuration
- `hosts/`: Host-specific configurations
- `modules/`: Reusable NixOS modules
- `lib/`: Helper functions
- `scripts/`: Installation and maintenance scripts

## Usage

### Installation

For local installation:
```bash
sudo ./scripts/install-local.sh --name <hostname>
```

For remote installation:
```bash
./scripts/install-remote.sh --name <hostname> --address <ip-address>
```

### Updating

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
