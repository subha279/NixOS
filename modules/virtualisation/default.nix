{ pkgs, ... }:

{
  # Virtualisation

  virtualisation.libvirtd = {
    enable = true;

    # Do not bring guests up while the machine is still booting.
    onBoot = "ignore";

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # Virt-Manager

  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # User Access

  users.users.subha.extraGroups = [
    "libvirtd"
  ];
}
