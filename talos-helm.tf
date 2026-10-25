provider "helm" {
  kubernetes = {
    host                   = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  }
}

locals {
  cilium_version         = "1.20.4"
  sealed_secrets_version = "v2.20.0"
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = local.cilium_version
  namespace  = "kube-system"

  wait    = true
  timeout = 600

  values = [yamlencode({
    ipam                 = { mode = "kubernetes" }
    kubeProxyReplacement = true
    k8sServiceHost       = "localhost"
    k8sServicePort       = 7445

    securityContext = {
      capabilities = {
        ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }
    cgroup = {
      autoMount = { enabled = false }
      hostRoot  = "/sys/fs/cgroup"
    }

    # LB(L2アナウンス)
    l2announcements    = { enabled = true }
    externalIPs        = { enabled = true }
    k8sClientRateLimit = { qps = 20, burst = 40 }
  })]

  depends_on = [talos_cluster_kubeconfig.this]
}

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = local.sealed_secrets_version
  namespace  = "kube-system"

  values = [yamlencode({
    fullnameOverride = "sealed-secrets-controller"
  })]

  depends_on = [helm_release.cilium]
}
