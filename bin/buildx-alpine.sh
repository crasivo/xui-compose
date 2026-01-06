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
DOCKER_BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DOCKER_IMAGE="crasivo/3x-ui"
XUI_VERSION=null

# Buildx
BUILDX_GITHUB=0
BUILDX_DOCKERHUB=0
BUILDX_PLATFORM='linux/amd64,linux/386,linux/s390x,linux/arm64,linux/arm/v7,linux/arm/v6'
BUILDX_ARGS=''

# ----------------------------------------------------------------
# Functions
# ----------------------------------------------------------------

function _build_latest_version_alpine() {
    local full_version="${2#v}"
    # shellcheck disable=SC2155
    local minor_version="$(echo "$full_version" | cut -d. -f1,2)"
    # Define prefixes
    local buildx_image_prefixes=()
    [[ $BUILDX_GITHUB == 1 ]] && buildx_image_prefixes+=(ghcr.io)
    [[ $BUILDX_DOCKERHUB == 1 ]] && buildx_image_prefixes+=(docker.io)
    # Define tags
    local buildx_tags=()
    for prefix in "${buildx_image_prefixes[@]}"; do
        buildx_tags+=("--tag=$prefix/$1:$full_version")
        buildx_tags+=("--tag=$prefix/$1:$full_version-alpine")
        buildx_tags+=("--tag=$prefix/$1:v$full_version")
        buildx_tags+=("--tag=$prefix/$1:v$full_version-alpine")
        buildx_tags+=("--tag=$prefix/$1:$minor_version")
        buildx_tags+=("--tag=$prefix/$1:$minor_version-alpine")
        buildx_tags+=("--tag=$prefix/$1:v$minor_version")
        buildx_tags+=("--tag=$prefix/$1:v$minor_version-alpine")
        buildx_tags+=("--tag=$prefix/$1:alpine")
        buildx_tags+=("--tag=$prefix/$1:alpine-$S_EXEC_DATE")
        buildx_tags+=("--tag=$prefix/$1:latest")
    done

    # shellcheck disable=SC2178
    buildx_tags="${buildx_tags[*]}"
    # shellcheck disable=SC2086
    # shellcheck disable=SC2128
    docker buildx build \
        --platform="$BUILDX_PLATFORM" \
        --file="$S_DOCKER_DIR/images/Dockerfile.alpine" \
        --build-arg="BUILD_DATE=$DOCKER_BUILD_DATE" \
        --build-arg="XUI_VERSION=$full_version" \
        $buildx_tags \
        $BUILDX_ARGS \
        $S_DOCKER_DIR
}

function _build_specified_version_alpine() {
    local full_version="${2#v}"
    # Define prefixes
    local buildx_image_prefixes=()
    [[ $BUILDX_GITHUB == 1 ]] && buildx_image_prefixes+=(ghcr.io)
    [[ $BUILDX_DOCKERHUB == 1 ]] && buildx_image_prefixes+=(docker.io)
    # Define tags
    local buildx_tags=()
    for prefix in "${buildx_image_prefixes[@]}"; do
        buildx_tags+=("--tag=$prefix/$1:$full_version")
        buildx_tags+=("--tag=$prefix/$1:$full_version-alpine")
        buildx_tags+=("--tag=$prefix/$1:v$full_version")
        buildx_tags+=("--tag=$prefix/$1:v$full_version-alpine")
    done

    # shellcheck disable=SC2178
    buildx_tags="${buildx_tags[*]}"
    # shellcheck disable=SC2086
    # shellcheck disable=SC2128
    docker buildx build \
        --platform="$BUILDX_PLATFORM" \
        --file="$S_DOCKER_DIR/images/Dockerfile.alpine" \
        --build-arg="BUILD_DATE=$DOCKER_BUILD_DATE" \
        --build-arg="XUI_VERSION=$full_version" \
        $buildx_tags \
        $BUILDX_ARGS \
        $S_DOCKER_DIR
}

# ----------------------------------------------------------------
# Commands
# ----------------------------------------------------------------

function _cmd_build_collection() {
    # shellcheck disable=SC2155
    local releases="$(curl -s https://api.github.com/repos/MHSanaei/3x-ui/releases?per_page=5 | jq -r 'sort_by(.published_at) | .[].tag_name')"
    if [[ $releases == 'null' ]]; then
        echo "[ERROR] GitHub API: Request limit exceeded."
        exit 1
    fi

    # shellcheck disable=SC2206
    releases=($releases)
    for v in "${releases[@]:0:4}"; do
        _build_specified_version_alpine "$DOCKER_IMAGE" "$v"
    done

    # Build latest
    _build_latest_version_alpine "$DOCKER_IMAGE" "${releases[4]}"
}

function _cmd_build_latest() {
    # shellcheck disable=SC2155
    local release="$(curl -s https://api.github.com/repos/MHSanaei/3x-ui/releases/latest | jq -r '.tag_name')"
    if [[ $release == 'null' ]]; then
        echo "[ERROR] GitHub API: Request limit exceeded."
        exit 1
    fi

    _build_latest_version_alpine "$DOCKER_IMAGE" "$release"
}

function _cmd_build_prev() {
    # shellcheck disable=SC2155
    local release="$(curl -s https://api.github.com/repos/MHSanaei/3x-ui/releases | jq -r '.[1].tag_name')"
    if [[ $release == 'null' ]]; then
        echo "[ERROR] GitHub API: Request limit exceeded."
        exit 1
    fi

    _build_specified_version_alpine "$DOCKER_IMAGE" "$release"
}

function _cmd_build_specified() {
    _build_specified_version_alpine "$DOCKER_IMAGE" "$XUI_VERSION"
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
        XUI_VERSION="$1"
        shift
        ;;
    *)
        echo "[ERROR] Undefined 3X-UI release - $1"
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
        --dockerhub)
            BUILDX_DOCKERHUB=1
            shift
            ;;
        --github)
            BUILDX_GITHUB=1
            shift
            ;;
        --platform=*)
            BUILDX_PLATFORM="${i#*=}"
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
