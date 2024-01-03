{ pkgs, config, lib, ... }:
let
  # https://github.com/NixOS/nixpkgs/issues/147801
  cephMonitoringSudoersCommandsAndPackages = [
    {
      package = pkgs.smartmontools;
      sudoersExtraRule = { # entry for `security.sudo.extraRules`
        users = [ config.users.users.ceph.name ];
        commands = [{
          command =
            "${lib.getBin pkgs.smartmontools}/bin/smartctl -x --json=o /dev/*";
          options = [ "NOPASSWD" ];
        }];
      };
    }
    {
      package = pkgs.nvme-cli;
      sudoersExtraRule = { # entry for `security.sudo.extraRules`
        users = [ config.users.users.ceph.name ];
        commands = [{
          command = "${
              lib.getBin pkgs.nvme-cli
            }/bin/nvme * smart-log-add --json /dev/*";
          options = [ "NOPASSWD" ];
        }];
      };
    }
  ];

  cephDeviceHealthMonitoringPathsOrPackages = [
    # Contains `sudo`. Ceph wraps this around the other health check programs.
    # Cannot use `pkgs.sudo` because that one is not SUID, see:
    # https://discourse.nixos.org/t/sudo-uid-issues/9133
    "/run/wrappers" # `systemd.services.<name>.path` adds the `bin/` subdir of this
  ] ++ map ({ package, ... }: package) cephMonitoringSudoersCommandsAndPackages;
in {
  imports = [ ../modules/ceph.nix ];
  networking.firewall.allowedTCPPorts = [ 8443 ];
  # services.smartd.enable = true;
  environment.systemPackages = with pkgs; [ smartmontools nvme-cli ];
  security.sudo.extraRules = map ({ sudoersExtraRule, ... }: sudoersExtraRule)
    cephMonitoringSudoersCommandsAndPackages;
  services.ceph = {
    mon = {
      enable = true;
      daemons = [ "fp0" ];
    };
    osd = {
      enable = true;
      daemons = [ "1" ];
    };
  };
  systemd.services = {
    ceph-osd-1 = { path = cephDeviceHealthMonitoringPathsOrPackages; };
    ceph-volumes = {
      wants = [ "local-fs.target" ];
      after = [ "local-fs.target" ];
      wantedBy = [ "ceph-osd-1.service" ];
      before = [ "ceph-osd-1.service" ];
      path = with pkgs; [ ceph util-linux lvm2 ];
      script = "ceph-volume lvm activate --all --no-systemd";
      serviceConfig = { Type = "oneshot"; };
    };
  };

}
