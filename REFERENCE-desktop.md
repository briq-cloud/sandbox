# What is in the sandbox

`x86_64`, Ubuntu 24.04.5 LTS, built 2026-10-27. Printed by `sandbox-versions` inside the image.

## Languages

| Language | Version | Package managers |
| --- | --- | --- |
| Python | 3.13.18 (`python`, `python3`), 3.12.16 (`python3.12`) | pip 26.2.2, uv 0.13.6, poetry 2.5.1 |
| Node.js | 24.22.1 | npm 11.19.1, pnpm 12.15.0, yarn 1.22.22, bun 1.4.4 |
| C/C++ | gcc 13.3.0 | make 4.3, cmake 3.28.3, ninja 1.11.1, pkg-config 1.8.1 |

Python libraries for `python`: numpy 2.5.4, pandas 3.1.0, matplotlib 3.11.2, openpyxl 3.1.5, python-docx 1.2.0, python-pptx 1.0.2, pypdf 6.21.3, requests 2.34.2, playwright 1.64.1

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
| `pandoc` | 3.1.3 | Document conversion |
| `pdftotext` | 24.02.0 | PDF text and pages (poppler) |
| `qpdf` | 11.9.0 | PDF structure |
| `ffmpeg` | 6.1.1 | Audio and video |
| `convert` | 6.9.12 | Images (ImageMagick) |
| `tesseract` | 5.3.4 | OCR, English |
| `dot` | 2.43.0 | Graphs (Graphviz) |

## Browser

Playwright 1.64.1 for Node.js (`playwright`, global) and Python (`python -m playwright`), with Chromium at `/opt/pw-browsers` (`PLAYWRIGHT_BROWSERS_PATH` is set). Firefox and WebKit are not installed.

## Desktop

A screen of 1280x800 (Xvfb 21.1.12), Openbox 3.6.1, and Chromium on it as the `desktop` user, its profile on the volume. The view: x11vnc 0.9.16 and noVNC 1.7.0, on `$PORT`. For agents: Playwright MCP 0.0.83 on that Chromium, and the desktop's MCP server (screenshot, zoom, click, type, key, scroll, drag) on port 8931, both behind `DESKTOP_TOKEN`. Input through xdotool 3.20160805.1.

## Image

`ghcr.io/briq-cloud/sandbox:desktop-2026-10-27`, 1308 MB compressed. The Dockerfile: [Dockerfile.desktop](Dockerfile.desktop).
