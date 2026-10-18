import {
  to = proxmox_virtual_environment_vm.homeassistant
  id = "betelgeuse/101"
}

data "proxmox_virtual_environment_vm" "vm101" {
  node_name = "betelgeuse"
  vm_id     = 101
}

resource "proxmox_virtual_environment_vm" "homeassistant" {
  name = "homeassistant"
  tags = [
    "community-script",
  ]
  node_name = "betelgeuse"
  vm_id     = 101
  acpi      = true
  bios      = "ovmf"
  boot_order = [
    "scsi0",
  ]
  delete_unreferenced_disks_on_destroy = true
  keyboard_layout                      = "en-us"
  machine                              = "q35"
  migrate                              = false
  on_boot                              = true
  protection                           = false
  purge_on_destroy                     = true
  reboot                               = false
  reboot_after_update                  = true
  scsi_hardware                        = "virtio-scsi-pci"
  started                              = true
  stop_on_destroy                      = false
  tablet_device                        = false
  template                             = false
  timeout_clone                        = 1800
  timeout_create                       = 1800
  timeout_migrate                      = 1800
  timeout_reboot                       = 1800
  timeout_shutdown_vm                  = 1800
  timeout_start_vm                     = 1800
  timeout_stop_vm                      = 300

  cpu {
    cores      = 2
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 1
    type       = "qemu64"
  }
  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    pre_enrolled_keys = false
    type              = "4m"
  }

  memory {
    dedicated      = 2048
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }
}

output "vm101_name" {
  value = data.proxmox_virtual_environment_vm.vm101.name
}

output "vm101_id" {
  value = data.proxmox_virtual_environment_vm.vm101.vm_id
}

output "vm101_node" {
  value = data.proxmox_virtual_environment_vm.vm101.node_name
}
