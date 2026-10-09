#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PODS="${ROOT_DIR}/scripts/pods.sh"

usage() {
  echo "Usage: $0 [image-tag]"
  echo "Start bluesky-services, adsim and sim, run the queueserver profile"
  echo "tests, then stop all of those pods (including any already running)."
  echo ""
  echo "The image tag is taken from the first argument, then NBS_IMAGE_TAG,"
  echo "then ci/image-tag.sh (the images CI built for the current commit)."
  echo ""
  echo "Environment:"
  echo "  NBS_IMAGE_REG                     registry prefix (default: set by scripts/pods.sh)"
  echo "  NBS_COLLECTION_PACKAGES           mounted as collection_packages (default: empty temp dir)"
  echo "  NBS_PROFILE_USE_LOCKED_PACKAGES   skip editable installs in tests (default: 1)"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

NBS_IMAGE_TAG="${1:-${NBS_IMAGE_TAG:-$("${SCRIPT_DIR}/image-tag.sh")}}"
NBS_PROFILE_USE_LOCKED_PACKAGES="${NBS_PROFILE_USE_LOCKED_PACKAGES-1}"
if [[ -z "${NBS_COLLECTION_PACKAGES:-}" ]]; then
  NBS_COLLECTION_PACKAGES="$(mktemp -d)"
fi
mkdir -p "${NBS_COLLECTION_PACKAGES}" /tmp/proposals
export NBS_IMAGE_TAG NBS_PROFILE_USE_LOCKED_PACKAGES NBS_COLLECTION_PACKAGES

dump_state() {
  podman ps -a || true
  podman ps -aq | xargs --no-run-if-empty -n 1 podman logs --tail 200 || true
}

stop_pods() {
  local rc=$?
  echo "== Stopping pods"
  "${PODS}" stop queueserver sim adsim bluesky-services || true
  podman ps -a || true
  exit "${rc}"
}

wait_for_containers() {
  local running name missing
  for _ in $(seq 1 60); do
    running="$(timeout 10s podman ps --format '{{.Names}}' || true)"
    missing=0
    for name in "$@"; do
      grep -q "${name}" <<<"${running}" || missing=1
    done
    if [[ "${missing}" -eq 0 ]]; then
      return 0
    fi
    sleep 2
  done
  echo "Timed out waiting for containers: $*" >&2
  dump_state
  return 1
}

echo "== Using image tag ${NBS_IMAGE_TAG}"
podman --version

LIST_OUTPUT="$("${PODS}" list)"
echo "${LIST_OUTPUT}"
grep -q "Available services" <<<"${LIST_OUTPUT}"

trap stop_pods EXIT

echo "== Starting bluesky-services"
"${PODS}" start bluesky-services
wait_for_containers bluesky-services_postgres bluesky-services_kafka bluesky-services_tiled_server

echo "== Starting adsim"
"${PODS}" start adsim
wait_for_containers adsim_adsim

echo "== Starting sim"
"${PODS}" start --dev sim
wait_for_containers sim_sim

echo "== Running queueserver profile tests"
"${PODS}" start --dev --teardown --test queueserver
