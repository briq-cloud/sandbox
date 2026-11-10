# briq sandbox

The image behind `briq_run({ recipe: "sandbox" })` on [briq](https://briq.cloud): a microVM of the
agent's own, where it runs scripts, tests and builds instead of on your machine.

```
ghcr.io/briq-cloud/sandbox:latest
```

Ubuntu 24.04. Python 3.13 and 3.12 through uv, with pip and poetry. Node.js 24 with npm, pnpm,
yarn and bun. A C toolchain. git, curl, jq, yq, ripgrep, tmux, vim. The clients of PostgreSQL,
Redis and SQLite; the servers run as briqs next to the sandbox. Nothing listens: the image runs
`sleep infinity`, and the agent runs commands in it.

Every tool and its version, as the last build left them: **[REFERENCE.md](REFERENCE.md)**. Inside
a sandbox, `sandbox-versions` prints the same.

## Tags

| Tag | What | Size |
| --- | --- | --- |
| `latest`, `<date>` | The default: languages, tools, database clients ([Dockerfile](Dockerfile)) | under a gigabyte |
| `full`, `full-<date>` | The default plus pandoc, poppler, qpdf, ffmpeg, ImageMagick, tesseract, Graphviz, the Python data libraries (NumPy, pandas, Matplotlib, openpyxl, python-docx, python-pptx, pypdf) and Playwright with Chromium ([Dockerfile.full](Dockerfile.full), [REFERENCE-full.md](REFERENCE-full.md)) | a few gigabytes |
| `desktop`, `desktop-<date>` | `full` plus a screen: Xvfb, Openbox and Chromium, a view in the browser (noVNC), and two MCP servers for agents: Playwright MCP on that Chromium and the screen in pixels ([Dockerfile.desktop](Dockerfile.desktop), [REFERENCE-desktop.md](REFERENCE-desktop.md)). What the [desktop](https://briq.cloud/cookbook/desktop) recipe runs | a few gigabytes |
| `3d`, `3d-<date>` | The default plus Blender (CPU Cycles), CadQuery, FreeCAD, OpenSCAD, trimesh, ezdxf, Pillow, NumPy and ffmpeg. Headless CAD and rendering ([Dockerfile.3d](Dockerfile.3d)) | a few gigabytes |
| `kvm`, `kvm-<date>` | Ubuntu 26.04 for code that runs virtual machines: a C toolchain, Python 3, Rust with the musl target, Firecracker and its jailer, ZFS tools, nftables, conntrack, udev, and `kvm-ready`, which prepares them at boot ([Dockerfile.kvm](Dockerfile.kvm), [REFERENCE-kvm.md](REFERENCE-kvm.md)). What the [kvm-sandbox](https://briq.cloud/cookbook/kvm-sandbox) recipe runs, on a briq with `/dev/kvm` | about a gigabyte |

The images are built every Monday and on every change here, for `linux/amd64`. A build takes the
latest patch of each line (Ubuntu 24.04, 26.04 for `kvm`; Python 3.13, Node 24). `latest` and `full` follow the
newest build; a date tag (`2026-10-19`, `full-2026-10-19`) never moves. On briq, the recipe runs
`latest`; pass `image` for another tag:

```text
briq_run({ recipe: "sandbox", image: "ghcr.io/briq-cloud/sandbox:full" })
```

## Run it elsewhere

```bash
docker run --rm -it ghcr.io/briq-cloud/sandbox:latest bash
```

## Build it

```bash
docker build -t sandbox .
docker build -t sandbox:full --build-arg BASE=sandbox -f Dockerfile.full .
docker build -t sandbox:desktop --build-arg BASE=sandbox:full -f Dockerfile.desktop .
docker build -t sandbox:3d --build-arg BASE=sandbox -f Dockerfile.3d .
docker run --rm sandbox:3d /opt/3d/smoke.sh
docker build -t sandbox:kvm -f Dockerfile.kvm .
docker run --rm sandbox sandbox-versions
```

## 3D examples

The `3d` image extends the default sandbox. It needs no display or GPU. CadQuery and its
libraries use an isolated Python 3.12 environment through `cad-python`; `python` stays unchanged.
`freecad-python` uses a separate conda-forge FreeCAD 1.1.3 environment and its matching Python.

Run these in a writable directory; each writes its outputs there:

```bash
cad-python /opt/3d/examples/plate.py  # plate.step, plate.stl; 60 × 40 × 6 mm, 8 mm hole
openscad -o part.stl /opt/3d/examples/part.scad
freecad-python /opt/3d/examples/freecad.py  # freecad.step, freecad.FCStd
blender -b --python-exit-code 1 -t 2 --python /opt/3d/examples/scene.py
# scene.blend, scene.glb, scene.png; CPU Cycles
```

Use `--python-exit-code 1` with Blender scripts so script failures fail the command. Run FreeCAD
scripts through `freecad-python` so exceptions also produce a nonzero exit code. The examples
are in [examples/3d](examples/3d); `/opt/3d/smoke.sh` checks them in a temporary directory.

## Links

- [Sandbox reference](https://briq.cloud/docs/sandbox): the same list on briq.cloud, with the
  sandbox's limits (sizes, disk, network, commands).
- [Run code in a sandbox](https://briq.cloud/docs/guides/run-code-in-a-sandbox): the guide.
- [The recipe](https://briq.cloud/cookbook/sandbox).

MIT licensed. The briq service is operated by Uplab SAS under its
[terms](https://briq.cloud/legal/terms).
