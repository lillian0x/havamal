resource "proxmox_virtual_environment_vm" "k3s_worker_2" {
  node_name = "betelgeuse"
  vm_id     = 108
  name      = "k3s-worker-2"
  tags      = ["k3s"]
  on_boot   = true

  description = <<-EOT
    ```bash
    sudo systemctl enable --now iscsid
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.0.103:6443 --token token" sh -s -
    ```
  EOT

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
    mac_address = "BC:24:11:D9:43:48"
    firewall    = true
  }

  network_device {
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "BC:24:11:03:C5:54"
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
  to = proxmox_virtual_environment_vm.k3s_worker_2
  id = "betelgeuse/108"
}
