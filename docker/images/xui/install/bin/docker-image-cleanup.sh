#!/bin/sh

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Apk (alpine)
rm -rf /var/cache/apk/* 2> /dev/null
rm -rf /var/lib/apk/* 2> /dev/null

# NodeJS
rm -rf /home/node/.cache/* 2> /dev/null
rm -rf /home/node/.npm/* 2> /dev/null
rm -rf /root/.cache/* 2> /dev/null
rm -rf /root/.npm/* 2> /dev/null
rm -rf /usr/local/share/.cache/* 2> /dev/null
