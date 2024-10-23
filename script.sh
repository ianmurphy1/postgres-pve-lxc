#!/usr/bin/env bash
set -e #x

# Remove existing SSH key from known_hosts file
# ssh config is setup to accept new keys from
# 192.168.1.46/24 IPs
sed -i '/^192.168.1.46/d' ~/.ssh/known_hosts

AGE_KEY=$(ssh -T root@192.168.1.46 <<EOL
  nixos-generate-config >/dev/null 2>&1
  nix-channel --update
  [[ ! -f ~/.ssh/id_ed25519 ]] && ssh-keygen -q -f ~/.ssh/id_ed25519 -N ''
  mkdir -p ~/.config/sops/age
  nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key" > ~/.config/sops/age/keys.txt
  nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"
EOL
)

key="${AGE_KEY}" yq -i '.keys[1] |= env(key)' ./.sops.yaml

sops updatekeys -y ./secrets.yaml

cp ./secrets.yaml ./nixos

scp -q root@192.168.1.46:/etc/nixos/hardware-configuration.nix ./nixos

ssh -qt root@192.168.1.46 'cat ~/.ssh/id_ed25519.pub'

#read -n 1 -r -p '
#  Add the above public key to github before continuing
#  Once added, press any key to continue
#'
