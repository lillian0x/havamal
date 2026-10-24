# Havamal

OpenTofu configuration for managing VMs and LXC containers on a Proxmox VE host, using the [bpg/proxmox](https://github.com/bpg/terraform-provider-proxmox) provider.

> [!WARNING]
> This is a personal learning projoct.
> Not intended for production use, so Use at your own risk.

## Managed resources

| Type | ID | Name | Purpose |
|------|-----|------|---------|
| VM  | 100 | meissa-pbs    | Proxmox Backup Server |
| VM  | 101 | homeassistant | Home Assistant OS |
| VM  | 103 | k3s-control-1 | k3s control plane |
| VM  | 104 | nfs-host      | RustFS / NFS storage host |
| VM  | 105 | llm           | LLM workloads (GPU passthrough) |
| VM  | 108 | k3s-worker-2  | k3s worker |
| VM  | 109 | k3s-worker-3  | k3s worker |
| LXC | 102 | adguard       | DNS / ad blocking |
| LXC | 106 | wireguard     | VPN |

## Requirements

- OpenTofu >= 1.7
- Proxmox VE 9.x (single node: `betelgeuse`)
- A Proxmox API token with sufficient privileges (see below)
- Optional: Nix (`nix develop` or `direnv allow`) for a reproducible dev shell

## Setup

```bash
tofu init
tofu plan
```

Secrets are passed via environment variables.
Copy `.env.example` and fill in your values.

### API token permissions

The token needs at least: `VM.Allocate`, `VM.Audit`, `VM.Config.*`, `VM.PowerMgmt`,
`Datastore.Audit`, `Datastore.AllocateSpace`, `Sys.Audit`.

## Importing a new resource

1. Inspect the current config: `qm config <vmid>` or `pct config <vmid>`.
2. Write the resource block and an `import` block:
   ```hcl
   import {
     to = proxmox_virtual_environment_vm.example
     id = "<node_name>/<vmid>"
   }
   ```
3. Run `tofu plan`. Confirm it shows `will be imported` with no destroy or replace.
4. Run `tofu apply`.
5. Run `tofu plan` again and confirm `No changes`, then remove the `import` block.

## LICENSE

Released under the [MIT License](LICENSE)
