resource "proxmox_virtual_environment_container" "wireguard" {
  node_name     = "betelgeuse"
  vm_id         = 106
  tags          = ["community-script", "network", "vpn"]
  unprivileged  = true
  start_on_boot = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 256
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 1
  }

  features {
    nesting = true
    keyctl  = true
  }

  console {
    enabled   = true
    tty_count = 2
    type      = "tty"
  }

  network_interface {
    name        = "eth0"
    bridge      = "vmbr0"
    mac_address = "BC:24:11:E9:1E:D6"
    firewall    = false
  }

  operating_system {
    template_file_id = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"
    type             = "alpine"
  }

  initialization {
    hostname = "wireguard"

    ip_config {
      ipv4 {
        address = "192.168.0.106/24"
        gateway = "192.168.0.254"
      }
      ipv6 {
        address = "auto"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      description,
      operating_system[0].template_file_id,
    ]
  }
}

import {
  to = proxmox_virtual_environment_container.wireguard
  id = "betelgeuse/106"
}
