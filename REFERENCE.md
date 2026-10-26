# What is in the sandbox

`x86_64`, Ubuntu 24.04.5 LTS, built 2026-10-26. Printed by `sandbox-versions` inside the image.

## Languages

| Language | Version | Package managers |
| --- | --- | --- |
| Python | 3.13.17 (`python`, `python3`), 3.12.15 (`python3.12`) | pip 26.2.2, uv 0.13.5, poetry 2.5.1 |
| Node.js | 24.22.1 | npm 11.19.1, pnpm 12.15.0, yarn 1.22.22, bun 1.4.4 |
| C/C++ | gcc 13.3.0 | make 4.3, cmake 3.28.3, ninja 1.11.1, pkg-config 1.8.1 |

## Database clients

The servers run as briqs next to the sandbox (the `postgres` and `redis` recipes); these are the clients.

| Client | Version | For |
| --- | --- | --- |
| `psql` | 16.15 | PostgreSQL (`pg_dump`, `pg_restore` too) |
| `redis-cli` | 7.0.15 | Redis |
| `sqlite3` | 3.45.1 | SQLite, a file |

## Tools

| Tool | Version | What for |
| --- | --- | --- |
| `git` | 2.43.0 | Version control (`git-lfs` too) |
| `curl` | 8.5.0 | HTTP |
| `wget` | 1.21.4 | HTTP |
| `ssh` | 9.6 | SSH client |
| `jq` | 1.7 | JSON |
| `yq` | 4.54.1 | YAML |
| `rg` | 14.1.0 | Search in files (ripgrep) |
| `fd` | 9.0.0 | Find files |
| `tmux` | 3.4 | Terminal multiplexer |
| `vim` | 9.1 | Editor |
| `nano` | 7.2 | Editor |
| `tar` | 1.35 | Archives (`zip`, `unzip`, `xz`, `bzip2` too) |
| `patch` | 2.7.6 | Apply diffs (`diff` too) |
| `nc` |  | TCP checks (netcat); `dig`, `ss`, `lsof` too |

## Image

`ghcr.io/briq-cloud/sandbox:2026-10-26`, 490 MB compressed. The Dockerfile: [Dockerfile](Dockerfile).
