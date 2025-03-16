data "sops_file" "secrets" {
  source_file = "/home/ian/dev/secrets/sops/postgres.secrets.yaml"
}

resource "proxmox_virtual_environment_file" "test_file" {
  content_type = "vztmpl"
  datastore_id = "hdd"
  node_name = "pve"

  source_file {
    path = "../generate/result/tarball/${tolist(fileset("../generate/result/tarball", "*"))[0]}"
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4yjNiSIJJLbzkZjz/i17xo6US8AUzCIDRYvLUd8a9S iano200@gmail.com",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6+FFKlLCiPAkeLHND/RPmamg+XxQ7fLFvq3cxz5Y+v ian@galaxy",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICh0QrZBTeoT4q1V2TbhmIwaSRv1iGtCVb161HLIPToz ian@nixos"
      ]
    }
  }

  memory {
    dedicated = 1024
  }

  disk {
    size = 60
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
