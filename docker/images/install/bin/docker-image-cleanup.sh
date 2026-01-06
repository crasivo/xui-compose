#!/bin/sh

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Root
rm -rf /root/.cache/*
rm -rf /root/.tmp/*

# Share
rm -rf /usr/share/info/*
if [ -d /usr/share/doc ]; then find /usr/share/doc -depth -type f ! -name copyright -delete; fi
if [ -d /usr/share/man ]; then find /usr/share/man -name '*.gz' -delete; fi

# Alpine
rm -rf /var/cache/apk/*;
rm -rf /var/lib/apk/*;
rm -rf /var/log/apk/*;

# Debian & Ubuntu
rm -rf /var/cache/apt/archives/*;
rm -rf /var/lib/apt/lists/*;
rm -rf /var/log/apt/*;
