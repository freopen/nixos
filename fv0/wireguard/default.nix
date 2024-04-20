{ lib, config, ... }: {
  age.secrets.wireguard = {
    file = ../../secrets/wireguard.age;
    owner = "systemd-network";
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];
  systemd.network = {
    enable = true;
    netdevs."99-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard.path;
        ListenPort = 51820;
      };
      wireguardPeers = lib.lists.imap0 (index: key: {
        wireguardPeerConfig = {
          AllowedIPs = [ "10.0.0.${toString (index + 2)}" ];
          PublicKey = key;
        };
      }) (lib.strings.splitString "\n"
        (lib.strings.fileContents ./client_keys.txt));
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.0.0.1/24" ];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPForward = true;
      };
    };
  };
}
