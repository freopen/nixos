let
  laptopKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo";
  serverKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqM6ywcMh+wcEIxV2nu9rFV5ybZbmQf51a8n5JmcIOi";
  raspiKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPxDLiP9ar9f7ks9UUA4yJHX0qypjBxKij5/Gck4A6U root@fp0";
in {
  "chat_bot.age".publicKeys = [ laptopKey serverKey ];
  "cloudflare_origin_cert.age".publicKeys = [ laptopKey serverKey ];
  "fishnet.age".publicKeys = [ laptopKey serverKey ];
  "miniflux.age".publicKeys = [ laptopKey serverKey ];
  "netdata.age".publicKeys = [ laptopKey serverKey ];
  "rclone.age".publicKeys = [ laptopKey serverKey ];
  "telemetry.age".publicKeys = [ laptopKey serverKey ];
  "wireguard.age".publicKeys = [ laptopKey serverKey ];
  "zigbee_network_key.age".publicKeys = [ laptopKey raspiKey ];
}
