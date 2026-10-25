resource "proxmox_virtual_environment_vm" "node" {
  for_each  = var.nodes
  name      = "${var.cluster_name}-${each.key}"
  node_name = var.pve_node
  vm_id     = each.value.vmid
  tags      = ["talos", each.value.role]

  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  stop_on_destroy = true

  agent { enabled = true }

  cpu {
    cores = each.value.role == "controlplane" ? 2 : 4
    type  = "host"
  }

  memory {
    dedicated = each.value.role == "controlplane" ? 4096 : 8192
  }

  disk {
    datastore_id = var.datastore
    import_from  = proxmox_virtual_environment_download_file.talos.id
    interface    = "scsi0"
    size         = 40
    iothread     = true
    discard      = "on"
  }

  dynamic "disk" {
    for_each = each.value.role == "worker" ? [1] : []
    content {
      datastore_id = var.datastore
      interface    = "scsi1"
      size         = 100
      iothread     = true
      discard      = "on"
      file_format  = "raw"
    }
  }

  network_device {
    bridge   = "vmbr0"
    vlan_id  = 20
    firewall = true
  }

  initialization {
    datastore_id = var.datastore
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }
    dns {
      servers = ["192.168.20.254"]
    }
  }
}
