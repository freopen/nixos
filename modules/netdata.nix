{ lib, config, ... }:
with lib; {
  options = {
    services.netdata.configs = mkOption {
      type = types.attrsOf
        (types.oneOf [ types.path types.str (types.attrsOf types.anything) ]);
      default = { };
    };
  };
  config = {
    services.netdata.configDir = builtins.mapAttrs (file: data:
      if builtins.isPath data || builtins.isString data then
        data
      else
        builtins.toFile (builtins.baseNameOf file)
        (if (builtins.match "(go.d|python.d)(.conf|/.*)" file) != null then
          generators.toYAML { } data
        else
          generators.toINI { } data)) config.services.netdata.configs;
  };
}
