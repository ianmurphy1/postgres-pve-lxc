data "local_file" "ssh_public_key" {
  filename = "/home/ian/.ssh/id_ed25519.pub"
}

data "sops_file" "secrets" {
  source_file = "../secrets.yaml"
}

resource "proxmox_virtual_environment_file" "test_file" {
  content_type = "vztmpl"
  datastore_id = "hdd"
  node_name = "pve"

  source_file {
    path = "../generate/result/tarball/nixos-system-x86_64-linux.tar.xz"
    file_name = "postgres-nixos.tar.xz"
  }
}

resource "proxmox_virtual_environment_container" "postgresql" {
  node_name = "pve"
  unprivileged = true
  tags = [
    "postgres"
  ]

  operating_system {
    type = "nixos"
    template_file_id = proxmox_virtual_environment_file.test_file.id
  }

  initialization {
    hostname = "postgresql"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      keys = [
        trimspace(data.local_file.ssh_public_key.content)
      ]
    }
  }

  disk {
    size = 20
    datastore_id = "local-lvm"
  }

  network_interface {
    name = "eth0"
    mac_address = "BC:24:11:F4:45:8A"
  }

  features {
    nesting = true
    #keyctl = true
  }
}

data "external" "lxc_ip" {
  program = ["bash", "./scripts/wait_for_ip.sh"]

  query = {
    lxc_id = proxmox_virtual_environment_container.postgresql.id
    iname = proxmox_virtual_environment_container.postgresql.network_interface[0].name
    token = data.sops_file.secrets.data["pve_token"]
  }
}

output "database_ip" {
  value = data.external.lxc_ip.result.ip_address
}
