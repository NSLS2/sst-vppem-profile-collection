#!/usr/bin/bash
set -e
set -o xtrace
pip install -e /home/xf07id1/collection_packages/nbs-viewer
$(dirname "$0")/viewer-start.sh