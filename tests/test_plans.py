import pytest
from nbs_bl.plans.scans import nbs_count, nbs_energy_scan
from nbs_bl.beamline import GLOBAL_BEAMLINE as bl
from bluesky.plans import count

def test_count_pco(RE, db):
    print("Running pco count test...")
    pco = bl['pco']
    print(f"PCO connection status: {pco.connected}", flush=True)
    pco.set_exposure(1.0)
    RE(count([pco], num=10))
    print("pco count test completed")
    run = db[-1]
    assert run.start['plan_name'] == "count"
    assert run.primary['data']['time'].shape == (10,)

def test_rbd(RE, db):
    print("Running rbd count test...")
    rbd = bl['rbd1']
    print(f"RBD connection status: {rbd.connected}", flush=True)
    rbd.set_exposure(1.0)
    RE(count([rbd], num=10))
    print("rbd count test completed")
    run = db[-1]
    assert run.start['plan_name'] == "count"
    assert run.primary['data']['time'].shape == (10,)

def test_nbs_count(RE, db):
    print("Running nbs count test...")
    RE(nbs_count(10, dwell=1.0))
    print("nbs count test completed")
    run = db[-1]
    assert run.start['plan_name'] == "nbs_count"
    assert run.primary['data']['time'].shape == (10,)

def test_nbs_energy_scan(RE, db):
    print("Running nbs energy scan test...")
    RE(nbs_energy_scan(700, 1.0, 705, dwell=1.0))
    print("nbs energy scan test completed")
    run = db[-1]
    assert run.start['plan_name'] == "nbs_energy_scan"
    assert run.primary['data']['time'].shape == (6,)
