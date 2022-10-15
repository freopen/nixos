{ lib, config, pkgs, ... }:
{
  age.secrets.wireguard = {
    file = ../../secrets/wireguard.age;
  };
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "10.0.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.wireguard.path;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
      '';
      peers = lib.lists.imap0
        (index: key: {
          allowedIPs = [
            "10.0.0.${toString (index + 2)}"
          ];
          publicKey = key;
        })
        (lib.strings.splitString "\n" (lib.strings.fileContents ./client_keys.txt));
    };
  };
}
