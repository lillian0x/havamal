resource "proxmox_virtual_environment_container" "adguard" {
  node_name     = "betelgeuse"
  vm_id         = 102
  tags          = ["adblock", "community-script"]
  unprivileged  = true
  start_on_boot = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 256
    swap      = 256
  }

  disk {
    datastore_id = "local-lvm"
    size         = 1
  }

  features {
    mount   = []
    nesting = true
    keyctl  = true
  }

  network_interface {
    name        = "eth0"
    bridge      = "vmbr0"
    mac_address = "BC:24:11:03:AC:C1"
    firewall    = false
  }

  operating_system {
    type             = "alpine"
    template_file_id = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"
  }

  initialization {
    hostname = "adguard"

    ip_config {
      ipv4 {
        address = "192.168.0.102/24"
        gateway = "192.168.0.254"
      }
      ipv6 {
        address = "auto"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [description, operating_system[0].template_file_id]
  }
}

import {
  to = proxmox_virtual_environment_container.adguard
  id = "betelgeuse/102"
}
