{ modulesPath, const, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./chess_erdos.nix
    ./fishnet.nix
    ./ghost.nix
    ./immich
    # ./miniflux.nix
    ./monitoring.nix
    ./nginx
    ./postgres.nix
    ./xray.nix
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
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
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
    interfaces.ens3.ipv4 = {
      addresses = [
        {
          address = "152.53.102.232";
          prefixLength = 22;
        }
      ];
      routes = [
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "152.53.100.1";
        }
      ];
    };
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
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
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
  services.qemuGuest.enable = true;
  users.users.root.openssh.authorizedKeys.keys = with const.ssh; [
    laptop
    phone
    fd0
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
