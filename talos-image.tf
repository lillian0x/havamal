resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = ["siderolabs/qemu-guest-agent"]
      }
    }
  })
}

resource "proxmox_virtual_environment_download_file" "talos" {
  node_name    = "betelgeuse"
  datastore_id = "local"
  content_type = "import"
  file_name    = "talos-${var.talos_version}-nocloud-amd64.qcow2"
  url          = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${var.talos_version}/nocloud-amd64.qcow2"
  overwrite    = false
}
