{ config, ... }:
{
  imports = [
    ./light.nix
    ./xiaomi.nix
  ];
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/hass"
      "/var/lib/mosquitto"
      "/var/lib/zigbee2mqtt"
    ];
  };
  services.nginx.virtualHosts."home.freopen.org" = {
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
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "esphome"
      "met"
      "mqtt"
      "radio_browser"
    ];
    config = {
      http = {
        server_host = "127.0.0.1";
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      default_config = { };
      recorder = {
        exclude = {
          entity_globs = [ "*" ];
        };
        commit_interval = 60 * 60;
      };
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
      advanced = {
        network_key = "!${config.age.secrets.zigbee_network_key.path} network_key";
        log_output = [ "syslog" ];
      };
    };
  };
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
    hostName = "home";
    publish = {
      enable = true;
      userServices = true;
      domain = true;
    };
  };
}
