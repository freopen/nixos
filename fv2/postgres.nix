{
  pkgs,
  ...
}:
{
  environment.persistence."/nix/persist".directories = [
    "/var/lib/pgbackrest"
    "/var/lib/postgresql"
    "/var/lib/private/pgadmin"
  ];
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureUsers = [
      {
        name = "root";
        ensureClauses.superuser = true;
      }
      {
        name = "pgadmin";
        ensureClauses.superuser = true;
      }
    ];
  };
  services.pgadmin = {
    enable = false;
    initialEmail = "freopen@freopen.org";
    initialPasswordFile = builtins.toFile "pgadmin-init-pass" "";
  };
}
