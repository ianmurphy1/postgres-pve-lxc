terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.66.0"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint = "https://pve.home:8006/"
  #api_token = var.pve_api_token
  api_token = var.root_api_token

  ssh {
    agent = true
  }
}
