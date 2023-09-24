{
  services.home-assistant.config = let
    button_profile = button: profile: {
      alias = "Light " + button;
      trigger = [{
        platform = "mqtt";
        topic = "zigbee2mqtt/switch/+/+/action";
        payload = button;
      }];
      action = [{
        service = "light.turn_on";
        data = { transition = 1; } // profile;
        target = { area_id = "{{ trigger.topic.split('/')[2] }}"; };
      }];
    };
  in {
    automation = [
      (button_profile "on-press" {
        brightness = 255;
        color_temp_kelvin = 4000;
      })
      (button_profile "up-press" {
        brightness = 180;
        color_temp_kelvin = 3000;
      })
      (button_profile "down-press" {
        brightness = 10;
        color_temp_kelvin = 3000;
      })
      (button_profile "off-press" { brightness = 0; })
      (button_profile "up-hold" { brightness_step = 20; })
      (button_profile "down-hold" { brightness_step = -20; })
    ];
  };
}
