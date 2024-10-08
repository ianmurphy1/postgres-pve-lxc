build:
  cd ./generate && \
    nix build .#postgres

deploy:
  cd ./terraform && \
    terraform plan -var-file ./variable.tfvars -out plan && \
    terraform apply -auto-approve plan

destroy:
  cd ./terraform && \
    terraform apply -auto-approve \
      -var-file ./variable.tfvars \
      -destroy

configure:
  cd ./ansible && \
    ansible-playbook playbook.yaml
