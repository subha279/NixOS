{ pkgs, ... }:

let
  vars = import ../../lib/variables.nix;
in

{

  virtualisation.libvirtd = {
    enable = true;

    onBoot = "ignore";

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  environment.systemPackages = [
    pkgs.virtiofsd
  ];


  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;


  users.users.${vars.username}.extraGroups = [
    "libvirtd"
  ];
}
