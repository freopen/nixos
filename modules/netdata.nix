{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkMerge
    ;
  cfg = config.services.netdata;
in
{
  options = {
    services.netdata = {
      isParent = mkOption {
        type = types.bool;
        default = false;
      };
      persistDir = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      configs = mkOption {
        type = types.attrsOf (
          types.oneOf [
            types.path
            types.str
            (types.attrsOf types.anything)
          ]
        );
        default = { };
      };
      metrics = mkOption {
        type = types.attrsOf types.port;
        default = { };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      age.secrets.netdata_stream.owner = "netdata";
      services.netdata = {
        config = {
          global = {
            "process scheduling policy" = "keep";
          };
          plugins = {
            "netdata monitoring" = true;
            "netdata monitoring extended" = true;
          };
        };

        configDir =
          builtins.mapAttrs
            (
              file: data:
              if builtins.isPath data || builtins.isString data then
                data
              else
                builtins.toFile (builtins.baseNameOf file) (
                  if (builtins.match "(go.d|python.d)(.conf|/.*)" file) != null then
                    lib.generators.toYAML { } data
                  else
                    lib.generators.toINI { } data
                )
            )
            (
              lib.attrsets.recursiveUpdate {
                "go.d/prometheus.conf" = {
                  autodetection_retry = 60;
                  jobs = lib.attrsets.mapAttrsToList (name: port: {
                    inherit name;
                    url = "http://127.0.0.1:${builtins.toString port}/metrics";
                  }) cfg.metrics;
                };
                "go.d/systemdunits.conf" = {
                  jobs = [
                    {
                      name = "all";
                      include = [ "*" ];
                    }
                  ];
                };
                "go.d.conf" = {
                  enabled = true;
                  default_run = true;
                  max_procs = 0;
                  modules = {
                    systemdunits = true;
                  };
                };
                "stream.conf" = config.age.secrets.netdata_stream.path;

              } config.services.netdata.configs
            );
      };
    }
    (mkIf (cfg.persistDir != null) {
      environment.persistence = {
        "${cfg.persistDir}".directories =
          builtins.map
            (dir: {
              directory = dir;
              user = "netdata";
              group = "netdata";
              mode = "0750";
            })
            [
              "/var/lib/netdata"
              "/var/cache/netdata"
            ];
      };
    })
    (mkIf cfg.isParent {
      age.secrets.netdata_stream.file = ../secrets/netdata_parent.age;
      age.secrets.netdata_cloud = {
        file = ../secrets/netdata_cloud.age;
        owner = "netdata";
      };
      networking.firewall.allowedTCPPorts = [ 19999 ];
      services.netdata = {
        package = pkgs.unstable.netdataCloud;
        claimTokenFile = config.age.secrets.netdata_cloud.path;
        config = {
          db = {
            mode = "dbengine";
            "storage tiers" = 4;
            "dbengine multihost disk space MB" = 256;
            "dbengine tier 1 multihost disk space MB" = 256;
            "dbengine tier 2 multihost disk space MB" = 256;
            "dbengine tier 3 multihost disk space MB" = 256;
            "dbengine tier 1 update every iterations" = 60;
            "dbengine tier 2 update every iterations" = 60;
            "dbengine tier 3 update every iterations" = 12;
          };
          ml.enabled = true;
          web =
            let
              certs = config.security.acme.certs."netdata.freopen.org".directory;
            in
            {
              "bind to" = "*=streaming^SSL=force localhost:19998=dashboard^SSL=optional";
              "ssl key" = "${certs}/key.pem";
              "ssl certificate" = "${certs}/fullchain.pem";
            };
        };
      };
      users.users.netdata.extraGroups = [ "nginx" ];
      users.groups.netdata-cert.members = [
        "netdata"
        "nginx"
      ];
      security.acme.certs."netdata.freopen.org" = {
        webroot = "/var/lib/acme/acme-challenge";
        group = "netdata-cert";
      };
      services.nginx.virtualHosts."netdata.freopen.org" = {
        forceSSL = true;
        useACMEHost = "netdata.freopen.org";
      };
    })
    (mkIf (!cfg.isParent) {
      age.secrets.netdata_stream.file = ../secrets/netdata_child.age;
      services.netdata = {
        package = pkgs.unstable.netdata;
        config = {
          web.mode = "none";
          db = {
            mode = "ram";
            "update every" = 10;
            retention = 24 * 60 * 60 / 10;
          };
          ml.enabled = false;
        };
      };
    })
  ]);
}
