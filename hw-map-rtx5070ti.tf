resource "proxmox_virtual_environment_hardware_mapping_pci" "gpu" {
  name = "rtx5070ti"

  map = [
    {
      id           = "10de:2c05"
      node         = "betelgeuse"
      path         = "0000:01:00.0"
      subsystem_id = "1462:5315"
      iommu_group  = 12
    },
  ]
}

resource "proxmox_virtual_environment_hardware_mapping_pci" "gpu_audio" {
  name = "rtx5070ti-audio"

  map = [
    {
      id           = "10de:22e9"
      node         = "betelgeuse"
      path         = "0000:01:00.1"
      subsystem_id = "10de:0000"
      iommu_group  = 12
    },
  ]
}
