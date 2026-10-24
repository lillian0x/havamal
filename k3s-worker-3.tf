resource "proxmox_virtual_environment_vm" "k3s_worker_3" {
  node_name = "betelgeuse"
  vm_id     = 109
  name      = "k3s-worker-3"
  tags      = ["k3s"]
  on_boot   = true

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 1
    sockets = 1
    type    = "x86-64-v2-AES"
    numa    = false
  }

  memory {
    dedicated = 4096
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
    mac_address = "BC:24:11:CE:60:42"
    firewall    = true
  }

  network_device {
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "BC:24:11:53:13:78"
    firewall    = true
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [initialization]
  }
}

import {
  to = proxmox_virtual_environment_vm.k3s_worker_3
  id = "betelgeuse/109"
}
