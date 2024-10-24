#!/usr/bin/env bash
set -ex
IP=${IP?'IP undefined'}
APP=${APP?'APP undefined'}
SECRETS_DIR="/home/ian/secrets/sops"

# Remove existing SSH key from known_hosts file
# ssh config is setup to accept new keys from
# 192.168.1.46/24 IPs
sed -i "/^${IP}/d" ~/.ssh/known_hosts

AGE_KEY=$(ssh -T root@${IP} <<EOL
  nixos-generate-config >/dev/null 2>&1
  nix-channel --update
  mkdir -p ~/.config/sops/age
  nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key" > ~/.config/sops/age/keys.txt
  nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"
EOL
)

key="${AGE_KEY}" \
	app="${APP}" \
	yq -i '.keys += ((.keys[] | select(anchor==env(app)) = env(key)) | .keys)' \
	/home/ian/dev/secrets/sops/.sops.yaml

sops \
	--config "${SECRETS_DIR}/.sops.yaml" \
	updatekeys -y "${SECRETS_DIR}/postgres.secrets.yaml"

scp -q root@${IP}:/etc/nixos/hardware-configuration.nix ./nixos
