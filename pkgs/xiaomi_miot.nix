# https://github.com/azuwis/nix-config/blob/master/pkgs/xiaomi_miot/default.nix
{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "al-one";
  domain = "xiaomi_miot";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "v${version}";
    hash = "sha256-IpL4e2mKCdtNu8NtI+xpx4FPW/uj1M5Rk6DswXmSJBk=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    hap-python
    micloud
    pyqrcode
    python-miio
  ];

  dontBuild = true;

  meta = with lib; {
    description = "Automatic integrate all Xiaomi devices to HomeAssistant via miot-spec, support Wi-Fi, BLE, ZigBee devices.";
    homepage = "https://github.com/al-one/hass-xiaomi-miot";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.asl20;
  };
}
