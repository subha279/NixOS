# NixOS Configuration Manager

Use one entry point for the entire configuration:

```bash
./setup.sh
```

Interactive menu:

1. Install / setup
2. Update configuration
3. Rebuild / switch
4. Dry rebuild
5. Check flake
6. Rollback
7. Refresh hardware configuration
8. Garbage collection
9. List generations

CLI mode is also available:

```bash
./setup.sh install
./setup.sh update
./setup.sh rebuild
./setup.sh dry
./setup.sh check
./setup.sh rollback
./setup.sh hardware
./setup.sh gc
```

The installer asks for the new user's identity, writes those values to `lib/variables.nix`, regenerates hardware configuration, validates the flake, rebuilds NixOS, and then invokes `passwd` interactively. Passwords are never stored in the Nix configuration.
