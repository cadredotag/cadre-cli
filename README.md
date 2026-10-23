<p align="center">
  <img src="assets/banner.webp" alt="Cadre" width="100%">
</p>

# Cadre CLI

The `cadre` command line app for the Cadre network.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/cadredotag/cadre-cli/main/install.sh | sh
```

Works on macOS (Apple silicon and Intel) and Linux (x86_64 and arm64, glibc 2.28 or newer). The
script checks the download against the release's SHA-256 sums and installs to `~/.local/bin`.

To install somewhere else, or pin a version:

```sh
curl -fsSL https://raw.githubusercontent.com/cadredotag/cadre-cli/main/install.sh | CADRE_INSTALL_DIR=/usr/local/bin CADRE_VERSION=v0.1.0 sh
```

Or download a binary from [Releases](../../releases) yourself.

## Run

```sh
cadre
```

`cadre --help` lists every command.
