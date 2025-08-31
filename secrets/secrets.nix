let
  ssh = (import ../const.nix).ssh;
  common = with ssh; [
    laptop
    phone
    fd0
  ];
  setKeys =
    names: keys:
    builtins.listToAttrs (
      builtins.map (x: {
        name = "${x}.age";
        value = {
          publicKeys = common ++ keys;
        };
      }) names
    );
in
(setKeys
  [
    "chat_bot"
    "fishnet"
  ]
  [
    ssh.fv0
    ssh.fv2
  ]
)
// (setKeys
  [
    "cloudflared_fp0"
    "fp0_restic"
    "zigbee_network_key"
  ]
  [ ssh.fp0 ]
)
// (setKeys
  [ "netdata_child" ]
  [
    ssh.fv0
    ssh.fp0
  ]
)
// (setKeys
  [
    "google_cloud_storage"
    "miniflux"
    "netdata_cloud"
    "netdata_parent"
    "pgbackrest"
    "rclone"
    "xray"
  ]
  [ ssh.fv2 ]
)
// (setKeys
  [ "grafana" ]
  [
    ssh.fv0
    ssh.fv2
    ssh.fp0
  ]
)
