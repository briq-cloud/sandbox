# What is in the sandbox

`x86_64`, Ubuntu 24.04.5 LTS, built 2026-11-10. Printed by `sandbox-versions` inside the image.

## Languages

| Language | Version | Package managers |
| --- | --- | --- |
| Python | 3.13.18 (`python`, `python3`), 3.12.16 (`python3.12`) | pip 26.3, uv 0.13.7, poetry 2.5.1 |
| Node.js | 24.22.2 | npm 11.19.1, pnpm 12.18.0, yarn 1.22.22, bun 1.4.4 |
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
| `yq` | 4.54.3 | YAML |
| `rg` | 14.1.0 | Search in files (ripgrep) |
| `fd` | 9.0.0 | Find files |
| `tmux` | 3.4 | Terminal multiplexer |
| `vim` | 9.1 | Editor |
| `nano` | 7.2 | Editor |
| `tar` | 1.35 | Archives (`zip`, `unzip`, `xz`, `bzip2` too) |
| `patch` | 2.7.6 | Apply diffs (`diff` too) |
| `nc` |  | TCP checks (netcat); `dig`, `ss`, `lsof` too |
| `ffmpeg` | 6.1.1 | Audio and video |

## 3D

CPU-only headless tools. Examples: `/opt/3d/examples`. Run FreeCAD scripts with `freecad-python` and its isolated Python environment at `/opt/freecad`.

| Tool | Version | What for |
| --- | --- | --- |
| `blender` | 4.5.16 | Modelling, GLB export, CPU Cycles rendering |
| `openscad` | 2021.01 | Scripted solid models |
| FreeCAD | 1.1.3 | Native CAD and STEP |

Python libraries for `cad-python` (isolated Python 3.12): cadquery 2.8.0, trimesh 5.2.0, ezdxf 1.4.5, Pillow 13.0.0, numpy 2.5.4

## Image

`ghcr.io/briq-cloud/sandbox:3d-2026-11-10`, 2577 MB compressed. The Dockerfile: [Dockerfile.3d](Dockerfile.3d).
