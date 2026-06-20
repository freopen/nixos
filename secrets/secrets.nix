let
  ssh = (import ../const.nix).ssh;
  publicKeys = with ssh; [
    laptop
    phone
    fd0
    fv2
  ];
in
builtins.listToAttrs (
  map (name: {
    name = "${name}.age";
    value = {
      inherit publicKeys;
    };
  }) [
    "fishnet"
    "ghost_backup"
    "google_cloud_storage"
    "grafana"
    "rclone"
    "xray"
  ]
)
