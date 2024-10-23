{
  config,
  lib,
  modulesPath,
  pkgs,
  inputs,
  ...
}:

let
  dataDir = "/var/lib/postgresql";
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${secretspath}/postgres.secrets.yaml";
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      root_ssh_key = {
        path = "${config.users.users.root.home}/.ssh/id_ed25519";
        owner = config.users.users.root.name;
        mode = "0600";
      };
    };
  };

  users.users.postgres = {
    name = "postgres";
    uid = config.ids.uids.postgres;
    group = "postgres";
    description = "PostgreSQL server user";
    home = "${dataDir}";
    useDefaultShell = true;
  };

  users.groups.postgres.gid = config.ids.gids.postgres;

  system.stateVersion = "24.11";
  services.sshd.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.root.password = "nixos";
  services.openssh.settings.PermitRootLogin = lib.mkOverride 999 "yes";
  services.getty.autologinUser = lib.mkOverride 999 "root";

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
