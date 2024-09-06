{
  modulesPath,
  const,
  impermanence,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    impermanence.nixosModules.impermanence
  ];
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=50%"
      "mode=755"
    ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  swapDevices = [
    {
      device = "/nix/swapfile";
      size = 32 * 1024;
    }
  ];
  networking = {
    useNetworkd = true;
    nftables = {
      enable = true;
      flushRuleset = false;
    };
    hostName = "fv2";
    interfaces.ens3.ipv6 = {
      addresses = [
        {
          address = "2a0a:4cc0:80:20f5::1";
          prefixLength = 64;
        }
      ];
      routes = [
        {
          address = "::";
          prefixLength = 0;
          via = "fe80::1";
        }
      ];
    };
  };
  time.timeZone = "UTC";
  system.autoUpgrade = {
    dates = "Sat, 09:00";
    allowReboot = true;
  };
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/nix/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  users.users.root.openssh.authorizedKeys.keys = with const.ssh; [
    laptop
    phone
  ];
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/root"
    ];
    files = [ "/etc/machine-id" ];
  };
}
