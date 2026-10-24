resource "proxmox_virtual_environment_vm" "pbs" {
  node_name   = "betelgeuse"
  vm_id       = 100
  name        = "meissa-pbs"
  description = "<a href='http://192.168.0.219:8007' target='_blank' rel='noopener noreferrer'>\n  Open PBS Web GUI\n</a>"
  on_boot     = true

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
    dedicated = 2048
  }

  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi0", "net0"]

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 32
    iothread     = true
    file_format  = "raw"
  }

  disk {
    datastore_id      = ""
    path_in_datastore = "/dev/disk/by-id/wwn-0x50014ee25ab6360f"
    interface         = "scsi2"
    backup            = false
    iothread          = false
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:8D:C2:0A"
    firewall    = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

import {
  to = proxmox_virtual_environment_vm.pbs
  id = "betelgeuse/100"
}
