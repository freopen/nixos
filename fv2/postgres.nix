{
  config,
  lib,
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
    extraPlugins = [
      # https://github.com/diogotcorreia/dotfiles/blob/nixos/packages/pgvecto-rs.nix
      (
        let
          major = lib.versions.major pkgs.postgresql_15.version;
        in
        pkgs.postgresql.stdenv.mkDerivation rec {
          pname = "pgvecto-rs";
          version = "0.2.1";

          buildInputs = [ pkgs.dpkg ];

          src = pkgs.fetchurl {
            url = "https://github.com/tensorchord/pgvecto.rs/releases/download/v${version}/vectors-pg${major}_${version}_amd64.deb";
            hash = "sha256-b4WbycGenKyWAJOlEJ4iOJLs2NaukdydOzjLBtqjcT0=";
          };

          dontUnpack = true;
          dontBuild = true;
          dontStrip = true;

          installPhase = ''
            mkdir -p $out
            dpkg -x $src $out
            install -D -t $out/lib $out/usr/lib/postgresql/${major}/lib/*.so
            install -D -t $out/share/postgresql/extension $out/usr/share/postgresql/${major}/extension/*.sql
            install -D -t $out/share/postgresql/extension $out/usr/share/postgresql/${major}/extension/*.control
            rm -rf $out/usr
          '';

          meta = {
            description = "pgvecto.rs extension for PostgreSQL: Scalable Vector database plugin for Postgres, written in Rust, specifically designed for LLM";
            homepage = "https://github.com/tensorchord/pgvecto.rs";
          };
        }
      )
    ];
    settings = {
      shared_preload_libraries = "vectors.so";
      archive_command = "${pkgs.pgbackrest}/bin/pgbackrest --stanza=localdb archive-push %p";
      archive_mode = "on";
      max_wal_senders = 3;
      wal_level = "replica";
    };
  };
  services.pgadmin = {
    enable = false;
    initialEmail = "freopen@freopen.org";
    initialPasswordFile = builtins.toFile "pgadmin-init-pass" "";
  };
  users.users.postgres.packages = [ pkgs.pgbackrest ];
  environment.etc."pgbackrest/pgbackrest.conf" = {
    user = "postgres";
    text = lib.generators.toINI { } {
      localdb = {
        pg1-path = config.services.postgresql.dataDir;
      };
      global = {
        log-level-console = "off";
        log-level-file = "off";
        log-level-stderr = "info";
        log-timestamp = "n";
        compress-type = "zst";
        repo1-path = "/var/lib/postgresql/pgbackrest";
        repo1-retention-full = 2;
        repo1-retention-diff = 5;
        repo1-bundle = "y";
        repo1-bundle-limit = "20MiB";
        repo1-bundle-size = "100MiB";
        repo1-block = "y";
        repo2-type = "s3";
        repo2-s3-endpoint = "https://b8ff5676aceb94ed88fc4b5a2f7a2658.r2.cloudflarestorage.com";
        repo2-s3-bucket = "fv2-pgbackrest";
        repo2-s3-region = "auto";
        repo2-cipher-type = "aes-256-cbc";
        repo2-storage-upload-chunk-size = "128MiB";
        repo2-retention-full = 2;
        repo2-retention-diff = 5;
        repo2-path = "/";
        repo2-bundle = "y";
        repo2-bundle-limit = "20MiB";
        repo2-bundle-size = "100MiB";
        repo2-block = "y";
      };
    };
  };
  age.secrets.pgbackrest = {
    file = ../secrets/pgbackrest.age;
    owner = "postgres";
    group = "postgres";
  };
  environment.etc."pgbackrest/conf.d/secrets.conf" = {
    user = "postgres";
    source = config.age.secrets.pgbackrest.path;
  };
  systemd.services =
    let
      backup-service = type: startAt: {
        script =
          let
            cmd = repo: ''
              ${pkgs.pgbackrest}/bin/pgbackrest \
                  --stanza=localdb \
                  --type=${type} \
                  --repo=${repo} \
                  backup
            '';
          in
          ''
            ${cmd "1"}
            ${cmd "2"}
            ${pkgs.pgbackrest}/bin/pgbackrest \
                --stanza=localdb \
                --output=text \
                --verbose \
                verify
          '';
        requisite = [ "postgresql.service" ];
        startAt = startAt;
        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
        };
      };
    in
    {
      postgresql-backup-monthly = backup-service "full" "*-*-01 00:00:00";
      postgresql-backup-daily = backup-service "diff" "*-*-02..31 00:00:00";
    };
}
