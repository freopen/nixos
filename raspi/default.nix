{ nixos-hardware, pkgs, ... }: {
  imports =
    [ nixos-hardware.nixosModules.raspberry-pi-4 ./ceph.nix ./home-assistant ];
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  fileSystems."/boot/firmware" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "fp0";
  system.autoUpgrade = {
    enable = true;
    dates = "Sat, 03:00";
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
    bootdir = "/boot/firmware";
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
  ];
  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
}
