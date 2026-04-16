import pytest
from IPython import get_ipython

ip = get_ipython()

def test_re_in_user_namespace():
    assert "RE" in ip.user_ns

def test_re_is_not_overwritten():
    RE = ip.user_ns["RE"]
    bl = ip.user_ns["bl"]
    assert RE is bl.run_engine
