{ config, ... }: {
  age.secrets.chat_bot = {
    file = ../secrets/chat_bot.age;
    owner = "freopen_chat_bot";
    group = "freopen_chat_bot";
  };
  services.freopen_chat_bot = {
    enable = true;
    envFile = config.age.secrets.chat_bot.path;
  };
}
