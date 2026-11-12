# What is in the sandbox

`x86_64`, Ubuntu 26.04.1 LTS, built 2026-11-12. Printed by `sandbox-versions` inside the image.

## Languages

| Language | Version | Package managers |
| --- | --- | --- |
| Python | 3.14.4 (`python`, `python3`) | pip 25.1.1 |
| C/C++ | gcc 15.2.0 | make 4.4.1, cmake 4.2.3, ninja 1.13.2, pkg-config 2.5.1 |
| Rust | 1.99.1 | cargo 1.99.1, rustup 1.29.3, targets: x86_64-unknown-linux-gnu x86_64-unknown-linux-musl  |

## Database clients

The servers run as briqs next to the sandbox (the `postgres` and `redis` recipes); these are the clients.

| Client | Version | For |
| --- | --- | --- |

## Tools

| Tool | Version | What for |
| --- | --- | --- |
| `git` | 2.53.0 | Version control (`git-lfs` too) |
| `curl` | 8.18.0 | HTTP |
| `wget` | 1.25.0 | HTTP |
| `ssh` | 10.2 | SSH client |
| `jq` | 1.8.1 | JSON |
| `rg` | 15.1.0 | Search in files (ripgrep) |
| `fd` | 10.3.0 | Find files |
| `tmux` | 3.6 | Terminal multiplexer |
| `vim` | 9.1 | Editor |
| `nano` | 8.7.1 | Editor |
| `tar` | 1.35 | Archives (`zip`, `unzip`, `xz`, `bzip2` too) |
| `patch` | 2.8 | Apply diffs (`diff` too) |
| `nc` |  | TCP checks (netcat); `dig`, `ss`, `lsof` too |

## Virtualization

Run `kvm-ready` once the briq is up (the kvm-sandbox recipe does at each boot): udev, the ZFS module, the cgroup controllers.

| Tool | Version | What for |
| --- | --- | --- |
| `firecracker` | 1.17.0 | Firecracker microVMs (`jailer` too) |
| `zfs` | 2.4.1 | ZFS tools; the module comes with the host's kvm kernel |
| `nft` | 1.1.6 | nftables |
| `conntrack` | 1.4.9 | Connection tracking |
| `qemu-img` | 10.2.1 | Disk images |
| `sgdisk` | 1.0.10 | Partitions |

## Image

`ghcr.io/briq-cloud/sandbox:kvm-2026-11-12`, 568 MB compressed. The Dockerfile: [Dockerfile.kvm](Dockerfile.kvm).
