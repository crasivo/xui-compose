#!/bin/sh

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Settings
# ----------------------------------------------------------------

XUI_DIR=${XUI_DIR:-/usr/local/x-ui}
XUI_INIT_ADMIN_LOGIN=${XUI_INIT_ADMIN_LOGIN:-}
XUI_INIT_ADMIN_PASSWORD=${XUI_INIT_ADMIN_PASSWORD:-}
XUI_PANEL_LISTEN_PORT=${XUI_PANEL_LISTEN_PORT:-2053}
XUI_BASE_WEB_PATH=${XUI_BASE_WEB_PATH:-/}

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# First start
if [ ! -f /etc/x-ui/x-ui.db ]; then
    if [ -n "$XUI_INIT_ADMIN_LOGIN" ]; then
        x-ui setting -username "$XUI_PANEL_PASSWORD"
    fi
    if [ -n "$XUI_PANEL_PASSWORD" ]; then
        x-ui setting -password "$XUI_PANEL_PASSWORD"
    fi
fi

# Force change
if [ -n "$XUI_PANEL_LISTEN_PORT" ]; then
    x-ui setting -port "$XUI_PANEL_LISTEN_PORT"
fi
if [ -n "$XUI_BASE_WEB_PATH" ]; then
    x-ui setting -webBasePath "$XUI_BASE_WEB_PATH"
fi
