{
  terraformArgs,
  modulesPath,
  flakeInputs,
  ...
}: {
  imports = [
    flakeInputs.disko.nixosModules.disko
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.useDHCP = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    initrd.availableKernelModules = ["ata_piix" "uhci_hcd"];
    kernelModules = ["kvm-intel"];
  };

  disko.devices.disk.main = {
    device = terraformArgs.disk or "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}