{
  config,
  lib,
  pkgs,
  ...
}:

let
  pgData = "/var/lib/postgresql";
in
{
  system.stateVersion = "24.05";
  services.sshd.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Hacky way to make sure that postgres
  # initdb can create what it needs to
  # in an LXC
  system.activationScripts.setup.text = ''
    #!/usr/bin/env bash

    if ! test -d ${pgData}; then
      mkdir -p "${pgData}"
      chown -R postgres:postgres "${pgData}"
    fi
  '';

  users.users.root.password = "nixos";
  services.openssh.settings.PermitRootLogin = lib.mkOverride 999 "yes";
  services.getty.autologinUser = lib.mkOverride 999 "root";
  services.postgresql = {
    enable = true;
    settings = {
      password_encryption = "scram-sha-256";
    };
    ensureDatabases = [
      "mydatabase"
      "vaultwarden"
    ];
    dataDir = "${pgData}";
    enableTCPIP = true;
    ensureUsers = [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
        local sameuser  all     peer        map=superuser_map
      # ipv4
        host  all      all     127.0.0.1/32   trust
        host  all      all     192.168.1.0/24 scram-sha-256
      # ipv6
        host all       all     ::1/128        trust
    '';
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root      postgres
      superuser_map      postgres  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      ALTER USER postgres WITH PASSWORD 'SCRAM-SHA-256$4096:mvNLaXPAq6D8H3L+xyPVtA==$sj8mKUkIfXM3GMED3D1WjwitTjhDsvDPSX9wHusu1ZY=:pq6+YO7mW6vdnyJ/BzwYDrgwWb8GMBXuHr65+J5utp0=';
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
