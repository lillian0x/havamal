resource "proxmox_virtual_environment_vm" "llm" {
  node_name = "betelgeuse"
  vm_id     = 105
  name      = "llm"
  on_boot   = false

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
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:3D:14:E7"
    firewall    = true
  }

  serial_device {
    device = "socket"
  }

  hostpci {
    device  = "hostpci0"
    mapping = proxmox_virtual_environment_hardware_mapping_pci.gpu.name
    pcie    = false
  }

  hostpci {
    device  = "hostpci1"
    mapping = proxmox_virtual_environment_hardware_mapping_pci.gpu_audio.name
    pcie    = false
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [initialization]
  }
}

import {
  to = proxmox_virtual_environment_vm.llm
  id = "betelgeuse/105"
}
