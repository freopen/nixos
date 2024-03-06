{ nixos-hardware, impermanence, pkgs, ... }: {
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-4
    impermanence.nixosModules.impermanence
    ./home-assistant
    ./netdata.nix
    ./nginx.nix
    ./storage.nix
  ];
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=50%" "mode=755" ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "btrfs";
      options = [ "subvol=/nix" "compress-force=zstd" "noatime" ];
    };
    "/persist" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      neededForBoot = true;
      fsType = "btrfs";
      options = [ "subvol=/persist" "compress-force=zstd" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
  };

  boot.loader.generic-extlinux-compatible.configurationLimit = 3;
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "fp0";
  networking.nftables.enable = true;
  system.autoUpgrade = {
    enable = true;
    dates = "Sat, 03:00";
    flake = "github:freopen/nixos";
    flags = [ "--no-write-lock-file" ];
    allowReboot = true;
  };
  services.journald.console = "/dev/tty1";
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  system.activationScripts.firmware-update = let
    configTxt = pkgs.writeText "config.txt" ''
      [pi4]
      kernel=u-boot-rpi4.bin
      enable_gic=1
      armstub=armstub8-gic.bin
      disable_overscan=1
      arm_boost=1
      [all]
      arm_64bit=1
      enable_uart=1
      avoid_warnings=1
    '';
    bootdir = "/boot";
  in ''
    (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf ${bootdir}/)
    # Add the config
    cp ${configTxt} ${bootdir}/config.txt
    # Add pi4 specific files
    cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin ${bootdir}/u-boot-rpi4.bin
    cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin ${bootdir}/armstub8-gic.bin
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb ${bootdir}/
    # https://github.com/NixOS/nixpkgs/issues/254921
    # BOOTFS=${bootdir} ${pkgs.raspberrypi-eeprom}/bin/rpi-eeprom-update -a
  '';
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo freopen@FREOPEN-DESKTOP"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5PxIXYZI8n8IQxAZRT5l9s3mlQ0/JGyTv1xMg4NHnh JuiceSSH"
  ];
  users.users.fv0-ports = {
    isSystemUser = true;
    group = "fv0-ports";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMIInbZIsN4/14kjcsGan6IBndSz9x3pQHmJW7odaZ0 fv0-ports"
    ];
  };
  users.groups.fv0-ports = { };
  age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log/journal"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/root"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
  systemd.additionalUpstreamSystemUnits = [ "systemd-time-wait-sync.service" ];
  systemd.services.systemd-time-wait-sync.wantedBy = [ "multi-user.target" ];
  systemd.targets.timers.after = [ "time-sync.target" ];
}
