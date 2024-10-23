{ config, lib, pkgs, inputs, ...}:

let
  dataDir = "/var/lib/postgresql";
in
{
  sops.secrets = {
    postgres_user_pass = {
      owner = "postgres";
    };
    authelia_user_pass = {
      owner = "postgres";
    };
  };

  systemd.services.postgresql = {
    serviceConfig = {
      StateDirectory = "postgresql";
      StateDirectoryMode = "0750";
    };
  };
  services.postgresql = {
    package = pkgs.postgresql;
    enable = true;
    settings = {
      password_encryption = "scram-sha-256";
    };
    dataDir = "${dataDir}";
    ensureDatabases = [
      "authelia"
    ];
    enableTCPIP = true;
    ensureUsers = [
      {
        name = "authelia";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser origin-address auth-method
        local all       postgres trust
        local sameuser  all      peer          map=superuser_map
      # ipv4
        #host  all      all     127.0.0.1/32   trust
        host  all      all     192.168.1.0/24 scram-sha-256
      # ipv6
        #host all       all     ::1/128        trust
    '';
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root      postgres
      superuser_map      postgres  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';
  };

  systemd.services."user_migrations" = {
    wantedBy = [
      "postgresql.service"
      "multi-user.target"
    ];
    after = ["postgresql.service"];
    environment = {
      PSQL = "psql --port=5432";
    };
    path = [ pkgs.postgresql ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${pkgs.bash}/bin/bash ${config.sops.templates.db_migrations.path}";
    };
  };

  sops.templates.db_migrations = {
    owner = "postgres";
    content = ''
        $PSQL -c "ALTER USER postgres WITH PASSWORD '${config.sops.placeholder.postgres_user_pass}'";
        $PSQL -c "ALTER USER postgres WITH PASSWORD '${config.sops.placeholder.authelia_user_pass}'";
    '';
  };
}
