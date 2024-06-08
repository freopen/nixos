{ lib, config, ... }:
{
  options = {
    services.netdata.configs = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.path
          lib.types.str
          (lib.types.attrsOf lib.types.anything)
        ]
      );
      default = { };
    };
  };
  config = {
    services.netdata.configDir = builtins.mapAttrs (
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
    ) config.services.netdata.configs;
  };
}
