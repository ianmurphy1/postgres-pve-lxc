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
  ./script.sh

update:
  cd ./nixos && \
  nixos-rebuild switch --flake .#postgres --target-host root@192.168.1.46

doit:
  just build deploy secrets update
