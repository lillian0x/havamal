locals {
  cluster_endpoint = "https://${var.vip_endpoint}:6443"
  cp_ips           = [for k, v in var.nodes : v.ip if v.role == "controlplane"]
  worker_ips       = [for k, v in var.nodes : v.ip if v.role == "worker"]
  hostname_patch = { for k, v in var.nodes : k => yamlencode({
    apiVersion = "v1alpha1"
    kind       = "HostnameConfig"
    hostname   = "${var.cluster_name}-${k}"
    auto       = "off"
  }) }
  install_patch = { for k, v in var.nodes : k => yamlencode({
    apiVersion = "v1alpha1"
    kind       = "UnattendedInstallConfig"
    installer = {
      image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.this.id}:${var.talos_version}"
    }
    provisioning = {
      diskSelector = {
        match = "disk.dev_path == \"/dev/sda\""
      }
    }
  }) }
  longhorn_volume_patch = { for k, v in var.nodes : k => yamlencode({
    apiVersion = "v1alpha1"
    kind       = "UserVolumeConfig"
    name       = "longhorn"
    provisioning = {
      diskSelector = { match = "!system_disk" }
      minSize      = "50GB"
    }
  }) if v.role == "worker" }

  longhorn_kubelet_patch = { for k, v in var.nodes : k => yamlencode({
    machine = {
      kubelet = {
        extraMounts = [{
          destination = "/var/mnt/longhorn"
          type        = "bind"
          source      = "/var/mnt/longhorn"
          options     = ["bind", "rshared", "rw"]
        }]
      }
    }
  }) if v.role == "worker" }
  vip_patch = { for k, v in var.nodes : k => yamlencode({
    machine = {
      network = {
        interfaces = [{
          interface = "eth0"
          dhcp      = false
          addresses = ["${v.ip}/24"]
          routes    = [{ network = "0.0.0.0/0", gateway = var.gateway }]
          vip       = { ip = var.vip_endpoint }
        }]
      }
    }
  }) if v.role == "controlplane" }
  node_patches = { for k, v in var.nodes : k => concat(
    [local.hostname_patch[k], local.install_patch[k]],
    compact([lookup(local.vip_patch, k, "")]),
    contains(keys(local.longhorn_volume_patch), k) ? [local.longhorn_volume_patch[k]] : [],
    # local.fw_rules[v.role],
  ) }
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.cp_ips
  nodes                = concat(local.cp_ips, local.worker_ips)
}

resource "talos_machine_configuration_apply" "node" {
  for_each = var.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = each.value.role == "controlplane" ? data.talos_machine_configuration.cp.machine_configuration : data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip
  config_patches              = local.node_patches[each.key]

  depends_on = [proxmox_virtual_environment_vm.node]
}
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.cp_ips[0]
  depends_on           = [talos_machine_configuration_apply.node]
}

data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = local.cp_ips
  worker_nodes         = local.worker_ips
  endpoints            = local.cp_ips
  depends_on           = [talos_machine_bootstrap.this]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.cp_ips[0]
  depends_on           = [talos_machine_bootstrap.this]
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}
