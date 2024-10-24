build:
  cd ./generate && \
    nix build .#postgres

deploy:
  cd ./terraform && \
    terraform plan -out plan && \
    terraform apply -auto-approve plan

destroy:
  cd ./terraform && \
    terraform apply -auto-approve \
      -destroy

secrets:
  lxcsecrets

update:
  cd ./nixos && \
    nix flake update && \
    nixos-rebuild switch --flake .#postgres --target-host root@${IP}

doit:
  just build deploy secrets update
