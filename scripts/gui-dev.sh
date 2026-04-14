#!/usr/bin/bash
set -e
set -o xtrace
pip install -e /home/xf07id1/collection_packages/nbs-core
pip install -e /home/xf07id1/collection_packages/sst-base
pip install -e /home/xf07id1/collection_packages/nbs-gui
pip install -e /home/xf07id1/collection_packages/livetable
$(dirname "$0")/gui-start.sh

