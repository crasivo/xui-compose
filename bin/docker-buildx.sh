#!/usr/bin/env bash

set -o pipefail
set -o errtrace
set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Environments
# ----------------------------------------------------------------

# Context (constant)
S_EXEC_DATE=$(date +%Y%m%d)
S_FILEPATH=$(realpath "$0")
S_CONTEXT_DIR=$(dirname "$S_FILEPATH")
S_ROOT_DIR=$(realpath "$S_CONTEXT_DIR/../")
S_DOCKER_DIR="$S_ROOT_DIR/docker"

# Secrets (workflow/env)
GIT_COMMIT_HASH=${GIT_COMMIT_HASH:-}
GITHUB_IMAGE=${GITHUB_IMAGE:-}
GITHUB_LOGIN=${GITHUB_LOGIN:-crasivo}
GITHUB_TOKEN=${GITHUB_TOKEN:-}
DOCKERHUB_IMAGE=${DOCKERHUB_IMAGE:-}
DOCKERHUB_LOGIN=${DOCKERHUB_LOGIN:-crasivo}
DOCKERHUB_TOKEN=${DOCKERHUB_TOKEN:-}
XUI_RELEASE=${XUI_RELEASE:-}

# Options (arguments)
BUILDX_PLATFORM='linux/amd64,linux/386,linux/s390x,linux/arm64,linux/arm/v7,linux/arm/v6'
BUILDX_ARGS=''

# ----------------------------------------------------------------
# Functions
# ----------------------------------------------------------------

function _build_latest_version_alpine() {
    local full_version="${2#v}"
    # shellcheck disable=SC2155
    local minor_version="$(echo "$full_version" | cut -d. -f1,2)"

    # shellcheck disable=SC2086
    docker buildx build \
        --platform="$BUILDX_PLATFORM" \
        --file="$S_DOCKER_DIR/images/Dockerfile.alpine" \
        --tag="$1:latest" \
        --tag="$1:$S_EXEC_DATE" \
        --tag="$1:alpine" \
        --tag="$1:alpine-$S_EXEC_DATE" \
        --tag="$1:$full_version" \
        --tag="$1:v$full_version" \
        --tag="$1:$minor_version" \
        --tag="$1:v$minor_version" \
        --tag="$1:$full_version-alpine" \
        --tag="$1:v$full_version-alpine" \
        --tag="$1:$minor_version-alpine" \
        --tag="$1:v$minor_version-alpine" \
        --build-arg="XUI_RELEASE=$full_version" \
        $BUILDX_ARGS \
        $S_DOCKER_DIR
}

function _build_latest_version_trixie() {
    local full_version="${2#v}"
    # shellcheck disable=SC2155
    local minor_version="$(echo "$full_version" | cut -d. -f1,2)"
    # shellcheck disable=SC2086
    docker buildx build \
        --platform="$BUILDX_PLATFORM" \
        --file="$S_DOCKER_DIR/images/Dockerfile.trixie" \
        --tag="$1:debian" \
        --tag="$1:debian-$S_EXEC_DATE" \
        --tag="$1:trixie" \
        --tag="$1:trixie-$S_EXEC_DATE" \
        --tag="$1:$full_version-debian" \
        --tag="$1:v$full_version-debian" \
        --tag="$1:$minor_version-debian" \
        --tag="$1:v$minor_version-debian" \
        --tag="$1:$full_version-trixie" \
        --tag="$1:v$full_version-trixie" \
        --tag="$1:$minor_version-trixie" \
        --tag="$1:v$minor_version-trixie" \
        --build-arg="XUI_RELEASE=$full_version" \
        $BUILDX_ARGS \
        $S_DOCKER_DIR
}

function _build_latest_version_dockerhub() {
    # Login
    if [[ -z "$DOCKERHUB_LOGIN" ]] && [[ -z "$DOCKERHUB_TOKEN" ]]; then
        echo "$DOCKERHUB_TOKEN" | docker login docker.io -u "$DOCKERHUB_LOGIN" --password-stdin 1> /dev/null
    fi
    # Build & Push
    _build_latest_version_alpine "docker.io/$DOCKERHUB_IMAGE" "$1"
    _build_latest_version_trixie "docker.io/$DOCKERHUB_IMAGE" "$1"
    # Logout
    if [[ -z "$DOCKERHUB_LOGIN" ]] || [[ -z "$DOCKERHUB_TOKEN" ]]; then
        docker logout docker.io 2> /dev/null
    fi
}

function _build_latest_version_github() {
    # Login
    if [[ -z "$GITHUB_LOGIN" ]] && [[ -z "$GITHUB_TOKEN" ]]; then
        echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_LOGIN" --password-stdin 1> /dev/null
    fi
    # Build & Push
    _build_latest_version_alpine "ghcr.io/$GITHUB_IMAGE" "$1"
    _build_latest_version_trixie "ghcr.io/$GITHUB_IMAGE" "$1"
    # Logout
    if [[ -z "$GITHUB_LOGIN" ]] || [[ -z "$GITHUB_TOKEN" ]]; then
        docker logout ghcr.io 2> /dev/null
    fi
}

function _build_specified_version_alpine() {
    local full_version="${2#v}"
    # shellcheck disable=SC2086
    docker buildx build \
        --platform="$BUILDX_PLATFORM" \
        --file="$S_DOCKER_DIR/images/Dockerfile.alpine" \
        --tag="$1:$full_version" \
        --tag="$1:v$full_version" \
        --tag="$1:$full_version-alpine" \
        --tag="$1:v$full_version-alpine" \
        --build-arg="XUI_RELEASE=$full_version" \
        $BUILDX_ARGS \
        $S_DOCKER_DIR
}

function _build_specified_version_trixie() {
    local full_version="${2#v}"
    # shellcheck disable=SC2086
    docker buildx build \
        --platform="$BUILDX_PLATFORM" \
        --file="$S_DOCKER_DIR/images/Dockerfile.trixie" \
        --tag="$1:$full_version-debian" \
        --tag="$1:v$full_version-debian" \
        --tag="$1:$full_version-trixie" \
        --tag="$1:v$full_version-trixie" \
        --build-arg="XUI_RELEASE=$full_version" \
        $BUILDX_ARGS \
        $S_DOCKER_DIR
}

function _build_specified_version_dockerhub() {
    # Login
    if [[ -z "$DOCKERHUB_LOGIN" ]] && [[ -z "$DOCKERHUB_TOKEN" ]]; then
        echo "$DOCKERHUB_TOKEN" | docker login docker.io -u "$DOCKERHUB_LOGIN" --password-stdin 1> /dev/null
    fi
    # Build & Push
    _build_specified_version_alpine "docker.io/$DOCKERHUB_IMAGE" "$1"
    _build_specified_version_trixie "docker.io/$DOCKERHUB_IMAGE" "$1"
    # Logout
    if [[ -z "$DOCKERHUB_LOGIN" ]] || [[ -z "$DOCKERHUB_TOKEN" ]]; then
        docker logout docker.io 2> /dev/null
    fi
}

function _build_specified_version_github() {
    # Login
    if [[ -z "$GITHUB_LOGIN" ]] && [[ -z "$GITHUB_TOKEN" ]]; then
        echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_LOGIN" --password-stdin 1> /dev/null
    fi
    # Build
    _build_specified_version_alpine "ghcr.io/$GITHUB_IMAGE" "$1"
    _build_specified_version_trixie "ghcr.io/$GITHUB_IMAGE" "$1"
    # Logout
    if [[ -z "$GITHUB_TOKEN" ]] || [[ -z "$GITHUB_LOGIN" ]]; then
        docker logout ghcr.io 2> /dev/null
    fi
}

# ----------------------------------------------------------------
# Commands
# ----------------------------------------------------------------

function _cmd_build_collection() {
    # shellcheck disable=SC2155
    local releases="$(curl -sSL "https://api.github.com/repos/MHSanaei/3x-ui/releases?per_page=5" | jq -r '.[].tag_name')"
    if [[ $releases == 'null' ]]; then
        echo "[ERROR] GitHub API: Request limit exceeded."
        exit 1
    fi

    # shellcheck disable=SC2206
    releases=($releases)
    _build_latest_version_dockerhub "${releases[0]}"
    _build_latest_version_github "${releases[0]}"
    # shellcheck disable=SC2206
    releases=(${releases[@]:1})
    for v in "${releases[@]}"; do
        _build_specified_version_github "$v"
        _build_specified_version_dockerhub "$v"
    done
}

function _cmd_build_latest() {
    # shellcheck disable=SC2155
    local release="$(curl -s https://api.github.com/repos/MHSanaei/3x-ui/releases/latest | jq -r '.tag_name')"
    if [[ $release == 'null' ]]; then
        echo "[ERROR] GitHub API: Request limit exceeded."
        exit 1
    fi

    # Build
    _build_latest_version_dockerhub "$release"
    _build_latest_version_github "$release"
}

function _cmd_build_prev() {
    # shellcheck disable=SC2155
    local release="$(curl -s https://api.github.com/repos/OWNER/REPO/releases | jq -r '.[1].tag_name')"
    if [[ $release == 'null' ]]; then
        echo "[ERROR] GitHub API: Request limit exceeded."
        exit 1
    fi

    # Build
    _build_specified_version_github "$release"
    _build_specified_version_dockerhub "$release"
}

function _cmd_build_specified() {
    _build_specified_version_github "$XUI_RELEASE"
    _build_specified_version_dockerhub "$XUI_RELEASE"
}

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Check arguments
if [[ "$#" -lt 1 ]]; then
    echo "[ERROR] Illegal number of parameters"
    exit 1
fi

# Parse action
C_ACTION=latest
case "$1" in
    collection)
        C_ACTION=collection
        shift
        ;;
    last|latest)
        C_ACTION=latest
        shift
        ;;
    prev|previous)
        C_ACTION=previous
        shift
        ;;
    v*)
        C_ACTION=specified
        XUI_RELEASE="$i"
        shift
        ;;
    *)
        echo "[ERROR] Undefined 3X-UI release - $i"
        exit 1
        ;;
esac

# Parse options
for i in "$@"; do
    case "$i" in
        --env=*)
            # shellcheck disable=SC2046
            export $(grep -E '^#' "${i#*=}" | xargs)
            shift
            ;;
        --*)
            BUILDX_ARGS="$BUILDX_ARGS $i"
            shift
            ;;
    esac
done

# Execute action
case "$C_ACTION" in
    collection)
        _cmd_build_collection
        ;;
    latest)
        _cmd_build_latest
        ;;
    previous)
        _cmd_build_prev
        ;;
    specified)
        _cmd_build_specified
        ;;
esac
