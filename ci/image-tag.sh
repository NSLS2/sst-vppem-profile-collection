#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

IMAGE_INPUTS=(
  .dockerignore
  images
  pixi.toml
  pixi.lock
  scripts
  startup
)

usage() {
  echo "Usage: $0 [git-rev]"
  echo "Print the env-<hash> image tag for a commit (default: HEAD)."
  echo ""
  echo "The hash covers the committed contents of:"
  for input in "${IMAGE_INPUTS[@]}"; do
    echo "  - ${input}"
  done
  echo ""
  echo "CI publishes images under this tag, so the same tag can be used"
  echo "locally to pull the images built for a given commit."
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

REV="${1:-HEAD}"

cd -- "${ROOT_DIR}"

if [[ "${REV}" == "HEAD" ]] && ! git diff --quiet HEAD -- "${IMAGE_INPUTS[@]}"; then
  echo "Warning: uncommitted changes to image inputs are not reflected in this tag." >&2
fi

HASH="$(git ls-tree -r "${REV}" -- "${IMAGE_INPUTS[@]}" | sha256sum | cut -c 1-16)"
echo "env-${HASH}"
