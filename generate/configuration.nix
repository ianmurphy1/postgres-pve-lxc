{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  dataDir = "/var/lib/postgresql";
in
{
  imports = [

  ];
  system.stateVersion = "24.11";
  services.sshd.enable = true;
  users.users.postgres = {
    name = "postgres";
    uid = config.ids.uids.postgres;
    group = "postgres";
    description = "PostgreSQL server user";
    home = "${dataDir}";
    useDefaultShell = true;
  };

  users.groups.postgres.gid = config.ids.gids.postgres;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.root.password = "nixos";
  services.openssh.settings.PermitRootLogin = lib.mkOverride 999 "yes";
  services.getty.autologinUser = lib.mkOverride 999 "root";

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
