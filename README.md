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

The images are built every Monday and on every change here, for `linux/amd64`. A build takes the
latest patch of each line (Ubuntu 24.04, Python 3.13, Node 24). `latest` and `full` follow the
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
docker run --rm sandbox sandbox-versions
```

## Links

- [Sandbox reference](https://briq.cloud/docs/sandbox): the same list on briq.cloud, with the
  sandbox's limits (sizes, disk, network, commands).
- [Run code in a sandbox](https://briq.cloud/docs/guides/run-code-in-a-sandbox): the guide.
- [The recipe](https://briq.cloud/cookbook/sandbox).

MIT licensed. The briq service is operated by Uplab SAS under its
[terms](https://briq.cloud/legal/terms).
