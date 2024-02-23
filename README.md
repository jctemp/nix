# CONFIG-SYSTEM

![Static Badge](https://img.shields.io/badge/NixOS-System-036ffc?style=for-the-badge&logo=NixOS&labelColor=ffffff&color=036ffc)

---

The repository follows a hybrid approach (machine- and role-centric) to manage system configuration. Role and machine agnostic configurations are stored in the `common` directory. Machine-specific configurations are stored in the `machines` directory. Role-specific configurations are stored in the `roles` directory. It allows for easy reuse of configurations across different machines and roles.
