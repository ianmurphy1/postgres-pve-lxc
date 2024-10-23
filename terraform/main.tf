terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.66.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.1.1"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint = "https://pve.home:8006/"
  api_token = "root@pam!terraform=${data.sops_file.secrets.data["pve_token"]}"

  ssh {
    agent = true
  }
}
