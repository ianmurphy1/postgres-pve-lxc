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
  api_token = var.pve_api_token

  ssh {
    agent = true
  }
}
