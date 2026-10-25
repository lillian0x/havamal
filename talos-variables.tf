variable "pve_node" { default = "betelgeuse" }
variable "datastore" { default = "local-lvm" }
variable "talos_version" { default = "v1.14.4" }
variable "cluster_name" { default = "talos" }
variable "gateway" { default = "192.168.20.254" }
variable "vip_endpoint" { default = "192.168.20.100" }

variable "nodes" {
  default = {
    cp1 = { role = "controlplane", ip = "192.168.20.101", vmid = 401 }
    cp2 = { role = "controlplane", ip = "192.168.20.102", vmid = 402 }
    cp3 = { role = "controlplane", ip = "192.168.20.103", vmid = 403 }
    w1  = { role = "worker", ip = "192.168.20.111", vmid = 411 }
    w2  = { role = "worker", ip = "192.168.20.112", vmid = 412 }
  }
}
