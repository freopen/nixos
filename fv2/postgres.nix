{
  pkgs,
  ...
}:
{
  environment.persistence."/nix/persist".directories = [
    "/var/lib/postgresql"
  ];
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureUsers = [
      {
        name = "root";
        ensureClauses.superuser = true;
      }
    ];
  };
}
