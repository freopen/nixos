let
  laptopKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo";
  serverKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqM6ywcMh+wcEIxV2nu9rFV5ybZbmQf51a8n5JmcIOi";
in {
  "chat_bot.age".publicKeys = [ laptopKey serverKey ];
  "cloudflared.age".publicKeys = [ laptopKey serverKey ];
  "newrelic.age".publicKeys = [ laptopKey serverKey ];
  "wireguard.age".publicKeys = [ laptopKey serverKey ];
}
