resource "proxmox_virtual_environment_vm" "nfs_host" {
  node_name   = "betelgeuse"
  vm_id       = 104
  name        = "nfs-host"
  description = "<a href='http://192.168.0.104:9001' target='_blank' rel='noopener noreferrer'>\n  Open RustFS\n</a>"
  on_boot     = true

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
    dedicated = 2048
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0", "net0"]

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
  }

  disk {
    datastore_id      = ""
    path_in_datastore = "/dev/disk/by-id/wwn-0x50014ee216e9d5b4"
    interface         = "scsi1"
    backup            = false
    iothread          = true
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi2"
    size         = 200
    iothread     = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:2E:91:54"
    firewall    = true
  }

  network_device {
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "BC:24:11:9B:88:92"
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
  to = proxmox_virtual_environment_vm.nfs_host
  id = "betelgeuse/104"
}
