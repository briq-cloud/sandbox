# The briq sandbox: what an agent gets with `briq_run({ recipe: "sandbox" })` on briq.cloud.
#
# Ubuntu 24.04 with Python 3.13 (and 3.12) through uv, Node.js 24 with npm, pnpm, yarn and bun, a C
# toolchain, git, and the tools a shell session reaches for, plus the clients of the databases that
# run as briqs next to it. Nothing listens: the briq runs `sleep infinity` and the agent runs
# commands in it. What is inside, with versions, is REFERENCE.md, written by the build from
# `sandbox-versions`.
#
# Versions are not pinned here on purpose: the image is built again every week, and each build
# takes the latest patch of each line (Ubuntu 24.04, Python 3.13, Node 24). A date tag names one
# build: `ghcr.io/briq-cloud/sandbox:2026-10-19`.
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=UTC

# System, text and build tools, and the database clients.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg openssh-client \
    git git-lfs \
    jq tmux vim nano less tree file bc \
    tar zip unzip xz-utils bzip2 gzip \
    build-essential make cmake ninja-build pkg-config \
    libssl-dev libffi-dev zlib1g-dev \
    ripgrep fd-find patch diffutils \
    procps lsof iproute2 dnsutils netcat-openbsd \
    sqlite3 postgresql-client redis-tools \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && rm -rf /var/lib/apt/lists/*

# yq (Mike Farah's), a single binary from its releases.
RUN curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$(dpkg --print-architecture)" \
    -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# Python through uv: 3.13 is `python` and `python3`, 3.12 is `python3.12`. pip and poetry beside
# them, on the path.
ENV UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_BIN_DIR=/usr/local/bin \
    UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    UV_LINK_MODE=copy
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
RUN uv python install 3.12 3.13 --default --preview-features python-install-default \
  && python -m ensurepip --upgrade \
  && python -m pip install --no-cache-dir --upgrade pip \
  && ln -s "$(python -c 'import sys, os; print(os.path.join(os.path.dirname(sys.executable), "pip"))')" /usr/local/bin/pip \
  && ln -s /usr/local/bin/pip /usr/local/bin/pip3 \
  && uv tool install poetry

# Node.js 24 (the current LTS line, its latest release), npm, pnpm, yarn and bun.
RUN NODE_VERSION="$(curl -fsSL https://nodejs.org/dist/index.json | jq -r '[.[] | select(.version | startswith("v24."))][0].version')" \
  && case "$(dpkg --print-architecture)" in amd64) ARCH=x64 ;; arm64) ARCH=arm64 ;; *) echo "unsupported architecture" >&2; exit 1 ;; esac \
  && curl -fsSL "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-${ARCH}.tar.xz" -o /tmp/node.tar.xz \
  && curl -fsSL "https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt" -o /tmp/SHASUMS256.txt \
  && (cd /tmp && grep " node-${NODE_VERSION}-linux-${ARCH}.tar.xz\$" SHASUMS256.txt | sed 's#  node# */tmp/node#; s#node-.*#node.tar.xz#' | sha256sum -c -) \
  && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --no-same-owner \
  && rm /tmp/node.tar.xz /tmp/SHASUMS256.txt \
  && npm install -g --no-fund --no-audit pnpm yarn \
  && npm cache clean --force
ENV BUN_INSTALL=/usr/local
RUN curl -fsSL https://bun.sh/install | bash \
  && rm -rf /root/.bun /usr/local/bin/bunx 2>/dev/null; ln -sf /usr/local/bin/bun /usr/local/bin/bunx

# What is inside, as Markdown: `sandbox-versions` (REFERENCE.md is its output).
COPY bin/sandbox-versions /usr/local/bin/sandbox-versions
RUN chmod +x /usr/local/bin/sandbox-versions && sandbox-versions > /dev/null

# The agent's files: on briq, a volume. Kept so `cd /work` works on any run of the image.
WORKDIR /work

# Nothing to serve: the briq stays up for the commands the agent sends it.
CMD ["sleep", "infinity"]
