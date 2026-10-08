#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

cd -- "${ROOT_DIR}"

PODMAN_BUILD_ARGS="--ulimit nofile=131072:131072"

if [[ $# -eq 0 ]]; then
  exec podman-compose --podman-build-args="${PODMAN_BUILD_ARGS}" -f docker-compose.build.yml build
fi

exec podman-compose --podman-build-args="${PODMAN_BUILD_ARGS}" -f docker-compose.build.yml build "$@"
