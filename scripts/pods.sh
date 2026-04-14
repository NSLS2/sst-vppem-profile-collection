#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BEAMLINE_PODS_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

export BEAMLINE_PODS_DIR
export BEAMLINE_NAME="vppem"

if [[ -z "${NBS_IMAGE_REG:-}" ]]; then
  export NBS_IMAGE_REG="ghcr.io/nsls2/sst-vppem-profile-collection/vppem-"
fi

if [[ $# -eq 0 ]]; then
  exec nbs-pods start
fi

exec nbs-pods "$@"

