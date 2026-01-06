#!/bin/sh

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Environments
# ----------------------------------------------------------------

# Custom: Admin
XUI_ADMIN_USERNAME=${XUI_ADMIN_USERNAME:-}
XUI_ADMIN_USERNAME_FILE=${XUI_ADMIN_USERNAME_FILE:-}
XUI_ADMIN_PASSWORD=${XUI_ADMIN_PASSWORD:-}
XUI_ADMIN_PASSWORD_FILE=${XUI_ADMIN_PASSWORD_FILE:-}

# Custom: Web
XUI_WEB_BASEPATH=${XUI_WEB_BASEPATH:-}
XUI_WEB_CERT=${XUI_WEB_CERT:-}
XUI_WEB_CERT_KEY=${XUI_WEB_CERT_KEY:-}

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Admin
if [ -n "$XUI_ADMIN_USERNAME_FILE" ] && [ -f "$XUI_ADMIN_USERNAME_FILE" ]; then
  XUI_ADMIN_USERNAME=$(cat "$XUI_ADMIN_USERNAME_FILE");
fi
if [ -n "$XUI_ADMIN_PASSWORD_FILE" ] && [ -f "$XUI_ADMIN_PASSWORD_FILE" ]; then
  XUI_ADMIN_PASSWORD=$(cat "$XUI_ADMIN_PASSWORD_FILE");
fi
if [ -n "$XUI_ADMIN_USERNAME" ] && [ -n "$XUI_ADMIN_PASSWORD" ]; then
  /usr/local/bin/x-ui setting -username "$XUI_ADMIN_USERNAME" -password "$XUI_ADMIN_PASSWORD"
fi

# Web
if [ -n "$XUI_WEB_BASEPATH" ]; then
  /usr/local/bin/x-ui setting -webBasePath "$XUI_WEB_BASEPATH"
fi
if [ -f "$XUI_WEB_CERT" ] || [ -f "$XUI_WEB_CERT_KEY" ]; then
  /usr/local/bin/x-ui setting -webCert "$XUI_WEB_CERT" -webCertKey "$XUI_WEB_CERT_KEY"
fi
