#!/bin/sh
# Install the cadre CLI: downloads the release binary for this machine, checks its
# SHA-256 against the release's SHA256SUMS, and puts it in $CADRE_INSTALL_DIR
# (default ~/.local/bin).
#
#   curl -fsSL https://raw.githubusercontent.com/cadredotag/cadre-cli/main/install.sh | sh
#
# Options (environment): CADRE_VERSION=v0.1.0 (default: latest release),
# CADRE_INSTALL_DIR=/usr/local/bin, CADRE_REPO=owner/name.
set -eu

REPO="${CADRE_REPO:-cadredotag/cadre-cli}"
DIR="${CADRE_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${CADRE_VERSION:-latest}"

fail() { echo "cadre install: $*" >&2; exit 1; }

case "$(uname -s)" in
  Darwin) os=apple-darwin ;;
  Linux) os=unknown-linux-gnu ;;
  *) fail "unsupported system $(uname -s) (macOS and Linux only)" ;;
esac
case "$(uname -m)" in
  arm64 | aarch64) arch=aarch64 ;;
  x86_64 | amd64) arch=x86_64 ;;
  *) fail "unsupported CPU $(uname -m)" ;;
esac
target="$arch-$os"

# Rosetta: an Intel shell on Apple silicon should still get the native build
if [ "$os" = apple-darwin ] && [ "$arch" = x86_64 ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
  target="aarch64-apple-darwin"
fi

if [ "$VERSION" = latest ]; then
  base="https://github.com/$REPO/releases/latest/download"
else
  base="https://github.com/$REPO/releases/download/$VERSION"
fi

command -v curl >/dev/null 2>&1 || fail "curl is required"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

asset="cadre-$target.tar.gz"
echo "Downloading $asset ($VERSION) from $REPO"
curl -fsSL "$base/$asset" -o "$tmp/$asset" || fail "download failed: $base/$asset"
curl -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS" || fail "download failed: $base/SHA256SUMS"

want="$(grep " $asset\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)"
[ -n "$want" ] || fail "$asset is not listed in SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
  got="$(sha256sum "$tmp/$asset" | cut -d' ' -f1)"
else
  got="$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)"
fi
[ "$want" = "$got" ] || fail "checksum mismatch for $asset"

tar -xzf "$tmp/$asset" -C "$tmp"
mkdir -p "$DIR"
mv -f "$tmp/cadre" "$DIR/cadre"
chmod 755 "$DIR/cadre"
echo "Installed $("$DIR/cadre" --version) to $DIR/cadre"

case ":$PATH:" in
  *":$DIR:"*) echo "Run: cadre" ;;
  *) echo "Add $DIR to your PATH, for example:"
     echo "  echo 'export PATH=\"$DIR:\$PATH\"' >> ~/.zshrc   # or ~/.bashrc"
     echo "Then run: cadre" ;;
esac
