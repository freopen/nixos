{ pkgs, ... }:
{
  services.home-assistant = {
    customComponents = [ pkgs.xiaomi_miot ];
    extraComponents = [
      "ffmpeg"
      "local_calendar"
    ];
    config.automation = [
      {
        alias = "Feed";
        trigger = [
          {
            platform = "calendar";
            event = "start";
            offset = "0:0:0";
            entity_id = "calendar.feeder";
          }
        ];
        action = [
          {
            service = "xiaomi_miot.call_action";
            data = {
              entity_id = "button.mmgg_fi1_5eff_pet_food_out";
              siid = 2;
              aiid = 1;
              throw = false;
            };
          }
        ];
      }
      {
        alias = "Feed Alert";
        trigger = [
          {
            platform = "state";
            entity_id = [ "sensor.mmgg_fi1_5eff_device_fault" ];
            attribute = "pet_feeder.fault";
            not_to = 0;
          }
        ];
        action = [
          {
            service = "notify.mobile_app_sm_s926b";
            data = {
              message = "Pet feeder device fault";
            };
          }
        ];
      }
    ];
  };
}
