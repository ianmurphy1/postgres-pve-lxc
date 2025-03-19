{
  config,
  lib,
  modulesPath,
  pkgs,
  inputs,
  ...
}:

let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
    ./postgres.nix
    ./template.nix
  ];

  sops = {
    defaultSopsFile = "${secretspath}/postgres.secrets.yaml";
    age = {
      keyFile = "/root/.config/sops/age/keys.txt";
    };
  };

  system.stateVersion = "24.11";
  services.sshd.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  environment.systemPackages = with pkgs; [
    rclone
  ];

  users.users.root = {
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4yjNiSIJJLbzkZjz/i17xo6US8AUzCIDRYvLUd8a9S iano200@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6+FFKlLCiPAkeLHND/RPmamg+XxQ7fLFvq3cxz5Y+v ian@galaxy"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICh0QrZBTeoT4q1V2TbhmIwaSRv1iGtCVb161HLIPToz ian@nixos"
      ];
    };
  };
  services.openssh.settings.PermitRootLogin = lib.mkOverride 999 "yes";
  services.getty.autologinUser = lib.mkOverride 999 "root";

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
