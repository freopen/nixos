let 
  laptopKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo";
  serverKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqM6ywcMh+wcEIxV2nu9rFV5ybZbmQf51a8n5JmcIOi";
in
{
  "newrelic.age".publicKeys = [ laptopKey serverKey ];
  "shadowsocks.age".publicKeys = [ laptopKey serverKey ];
}
