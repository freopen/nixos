let
  ssh = (import ../const.nix).ssh;
  common = with ssh; [ laptop phone ];
  setKeys = names: keys:
    builtins.listToAttrs (builtins.map (x: {
      name = "${x}.age";
      value = { publicKeys = keys; };
    }) names);
in (setKeys [
  "chat_bot"
  "fishnet"
  "google_cloud_storage"
  "miniflux"
  "netdata"
  "netdata_stream_fv0"
  "fv0_ports"
  "rclone"
  "renterd"
  "telemetry"
  "wireguard"
] (common ++ [ ssh.fv0 ]))
// (setKeys [ "netdata_stream_fp0" "zigbee_network_key" ]
  (common ++ [ ssh.fp0 ]))
