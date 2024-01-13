{ modulesPath, chat_bot, chess_erdos, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./ceph.nix
    ./chat_bot.nix
    ./chess_erdos.nix
    ./fishnet.nix
    ./monitoring.nix
    ./nginx
    ./photoprism.nix
    ./wireguard
    chat_bot.nixosModules.freopen_chat_bot
    chess_erdos.nixosModules.default
  ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "ext4";
  };
  networking.hostName = "fv0";
  networking.interfaces.ens18.ipv6 = {
    addresses = [{
      address = "2a02:c206:2101:9040::1";
      prefixLength = 64;
    }];
    routes = [{
      address = "::";
      prefixLength = 0;
      via = "fe80::1";
    }];
  };
  system.autoUpgrade = {
    enable = true;
    dates = "Sat, 09:00";
    flake = "github:freopen/nixos";
    flags = [ "--no-write-lock-file" ];
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
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo freopen@FREOPEN-DESKTOP"
  ];
  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
}
