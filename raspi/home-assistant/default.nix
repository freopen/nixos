{ config, ... }: {
  imports = [ ./light.nix ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    virtualHosts."home.freopen.org" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123/";
        proxyWebsockets = true;
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
  services.home-assistant = {
    enable = true;
    extraComponents = [ "esphome" "met" "radio_browser" "mqtt" ];
    config = {
      http = {
        server_host = "127.0.0.1";
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      default_config = { };
    };
  };
  age.secrets.zigbee_network_key = {
    name = "zigbee_network_key.yaml";
    file = ../../secrets/zigbee_network_key.age;
    owner = "zigbee2mqtt";
    group = "zigbee2mqtt";
  };
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = {
        legacy_entity_attributes = false;
        legacy_triggers = false;
      };
      serial.port = "/dev/ttyUSB0";
      frontend.port = 8080;
      availability = true;
      advanced.network_key =
        "!${config.age.secrets.zigbee_network_key.path} network_key";
    };
  };
  services.mosquitto = {
    enable = true;
    listeners = [{
      acl = [ "pattern readwrite #" ];
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    }];
  };
}
