#!/usr/bin/env bash
set -euo pipefail
set -o xtrace

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
TESTS_DIR="${PROFILE_ROOT}/tests"

export TESTS_DIR
pip install -v -e /home/xf07id1/collection_packages/vppem --no-deps
echo "test-profile: pip install -e vppem (--no-deps) completed"
python -c "import importlib.util as u; print(u.find_spec('vppem'))"

PYTHONFAULTHANDLER=1 PYTHONUNBUFFERED=1 ipython --profile collection -c '
import os, sys, time

import pytest
print("test-profile: profile loaded, starting pytest at", time.strftime("%H:%M:%S"), flush=True)
rc = pytest.main(["-v", "-s",os.environ["TESTS_DIR"]])
print("test-profile: pytest finished with rc=", rc, flush=True)
sys.stdout.flush()
sys.stderr.flush()
os._exit(rc)
'
