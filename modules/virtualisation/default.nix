{ pkgs, ... }:

{
  # --------------------------------------------------
  # Virtualisation
  # --------------------------------------------------

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # --------------------------------------------------
  # Virt-Manager
  # --------------------------------------------------

  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # --------------------------------------------------
  # User Access
  # --------------------------------------------------

  users.users.subha.extraGroups = [
    "libvirtd"
  ];
}
