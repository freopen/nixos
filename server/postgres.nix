{ lib, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureUsers = [{
      name = "root";
      ensureClauses.superuser = true;
    }];
    extraPlugins = [
      # https://github.com/diogotcorreia/dotfiles/blob/nixos/packages/pgvecto-rs.nix
      (let major = lib.versions.major pkgs.postgresql_15.version;
      in pkgs.postgresql.stdenv.mkDerivation rec {
        pname = "pgvecto-rs";
        version = "0.2.0";

        buildInputs = [ pkgs.dpkg ];

        src = pkgs.fetchurl {
          url =
            "https://github.com/tensorchord/pgvecto.rs/releases/download/v${version}/vectors-pg${major}_${version}_amd64.deb";
          hash = "sha256-uPE76ofzAevJMHSjFHYJQWUh5NZotaD9dhaX84uDFiQ=";
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
          description =
            "pgvecto.rs extension for PostgreSQL: Scalable Vector database plugin for Postgres, written in Rust, specifically designed for LLM";
          homepage = "https://github.com/tensorchord/pgvecto.rs";
        };
      })
    ];
    settings = { shared_preload_libraries = "vectors.so"; };
    initialScript = builtins.toFile "init-sql-script" ''
      CREATE EXTENSION IF NOT EXISTS vectors;
      CREATE USER netdata;
      GRANT pg_monitor TO netdata;
    '';
  };
  users.users.postgres.extraGroups = [ "rclone" ];
  systemd.mounts = [{
    what = "/mnt/rclone/postgresql";
    where = "/var/lib/postgresql-backup";
    options = "bind";
    bindsTo = [ "rclone.service" ];
    after = [ "rclone.service" ];
    requiredBy = [ "postgresqlBackup.service" ];
    before = [ "postgresqlBackup.service" ];
  }];
  services.postgresqlBackup = {
    enable = true;
    startAt = "*-*-* 14:00:00";
    location = "/var/lib/postgresql-backup";
    compression = "zstd";
    compressionLevel = 10;
  };
}
