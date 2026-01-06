#!/bin/sh

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Environments
# ----------------------------------------------------------------

XUI_INSTALL_ARCH=${XUI_INSTALL_ARCH:-amd64}
XUI_INSTALL_DIR=${XUI_INSTALL_DIR:-/usr/local/x-ui}

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Check arguments
if [ "$#" -lt 1 ]; then
  echo "[ERROR] Illegal number of parameters";
  exit 1;
fi

# Define OS arch
case "$(uname -m)" in
  386 | i386)
    XUI_INSTALL_ARCH='386'
    ;;
  amd64 | x86_64)
    XUI_INSTALL_ARCH='amd64'
    ;;
  arm64 | armv8 | aarch64)
    XUI_INSTALL_ARCH='arm64'
    ;;
  armv7 | armv7l)
    XUI_INSTALL_ARCH='armv7'
    ;;
  armv6 | armv6l)
    XUI_INSTALL_ARCH='armv6'
    ;;
  s390x)
    XUI_INSTALL_ARCH='s390x'
    ;;
esac

# Download release
mkdir -p "$XUI_INSTALL_DIR"
if [ -n "$1" ] || [ "$1" = 'latest' ]; then
  curl -sSL "https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-$XUI_INSTALL_ARCH.tar.gz" \
    | tar -xzf - --strip-components 1 -C "$XUI_INSTALL_DIR"
else
  curl -sSL "https://github.com/MHSanaei/3x-ui/releases/download/v$1/x-ui-linux-$XUI_INSTALL_ARCH.tar.gz" \
    | tar -xzf - --strip-components 1 -C "$XUI_INSTALL_DIR"
fi

# Prepare binary
chmod +x "$XUI_INSTALL_DIR/x-ui"
ln -sf "$XUI_INSTALL_DIR/x-ui" "/usr/local/bin/x-ui"
