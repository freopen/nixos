let
  ssh = (import ../const.nix).ssh;
  commonKeys = with ssh; [
    laptop
    phone
    fd0
  ];
  fv2Keys = commonKeys ++ [ ssh.fv2 ];
  mkSecrets =
    publicKeys: names:
    builtins.listToAttrs (
      map (name: {
        name = "${name}.age";
        value = {
          inherit publicKeys;
        };
      }) names
    );
in
(mkSecrets fv2Keys [
  "fishnet"
  "ghost_backup"
  "google_cloud_storage"
  "grafana"
  "netdata_cloud"
  "netdata_parent"
  "rclone"
  "xray"
])
// (mkSecrets commonKeys [
  "netdata_child"
])
