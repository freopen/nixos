{
  modulesPath,
  chat_bot,
  const,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./chat_bot.nix
    ./fishnet.nix
    ./monitoring.nix
    chat_bot.nixosModules.freopen_chat_bot
  ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "ext4";
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];
  networking = {
    useNetworkd = true;
    nftables = {
      enable = true;
      flushRuleset = false;
    };
    hostName = "fv0";
    interfaces.ens18.ipv6 = {
      addresses = [
        {
          address = "2a02:c206:2101:9040::1";
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
  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
}
