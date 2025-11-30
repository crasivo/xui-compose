#!/bin/sh

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Execute entrypoint scripts
if [ -d '/docker-entrypoint.d' ]; then
    # shellcheck disable=SC2044
    for s in $(find '/docker-entrypoint.d' -maxdepth 1 -name '*.sh' | sort); do
        echo "[INFO] Docker entrypoint: Execute script ${s##*/}"
        sh "$s"
    done
fi

# Execute CMD
echo "[INFO] Docker entrypoint: Execute command - $*"
exec "$@"
