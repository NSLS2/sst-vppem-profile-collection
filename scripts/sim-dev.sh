#!/usr/bin/bash
set -e
set -o xtrace
if [[ -z "${NBS_PROFILE_USE_LOCKED_PACKAGES:-}" ]]; then
    pip install -e /home/xf07id1/collection_packages/nbs-sim
fi
$(dirname "$0")/sim-start.sh
