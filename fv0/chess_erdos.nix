{ ... }:
{
  services.chess_erdos = {
    enable = true;
  };
  services.netdata.metrics.chess_erdos = 4001;
}
