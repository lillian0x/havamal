resource "proxmox_virtual_environment_vm" "k3s_control_1" {
  node_name = "betelgeuse"
  vm_id     = 103
  name      = "k3s-control-1"
  tags      = ["k3s"]
  on_boot   = true

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
    numa    = false
  }

  memory {
    dedicated = 8192
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0", "net0"]

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 64
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:77:CF:FF"
    firewall    = true
  }

  network_device {
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "BC:24:11:1D:72:0D"
    firewall    = true
  }

  serial_device {
    device = "socket"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [initialization]
  }
}

import {
  to = proxmox_virtual_environment_vm.k3s_control_1
  id = "betelgeuse/103"
}
