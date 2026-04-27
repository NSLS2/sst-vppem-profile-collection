import pytest
from nbs_bl.plans.scans import nbs_count, nbs_energy_scan
from nbs_bl.plans.plan_stubs import set_exposure
from nbs_bl.beamline import GLOBAL_BEAMLINE as bl
from bluesky.plans import count


def test_set_exposure(RE):
    print("Running set exposure test...")
    pco = bl['pco']
    rbd = bl['rbd1']
    print(f"PCO default acquire time: {pco.cam.acquire_time.get(timeout=10)}", flush=True)
    print(f"RBD default acquire time: {rbd.exposure_time.get(timeout=10)}", flush=True)
    RE(set_exposure(1.0))
    print(f"PCO acquire time after set_exposure: {pco.cam.acquire_time.get(timeout=10)}", flush=True)
    print(f"RBD acquire time after set_exposure: {rbd.exposure_time.get(timeout=10)}", flush=True)
    assert pco.cam.acquire_time.get(timeout=10) == 1.0
    assert rbd.exposure_time.get(timeout=10) == 1.0
    print("set exposure test completed")

def test_count_pco(RE, db):
    print("Running pco count test...")
    pco = bl['pco']
    pco.set_exposure(1.0)
    RE(count([pco], num=10))
    print("pco count test completed")
    run = db[-1]
    assert run.start['plan_name'] == "count"
    assert run.primary['data']['time'].shape == (10,)

def test_rbd(RE, db):
    print("Running rbd count test...")
    rbd = bl['rbd1']
    rbd.set_exposure(1.0)
    RE(count([rbd], num=10))
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
    assert run.start['plan_name'] == "nbs_list_scan"
    assert run.primary['data']['time'].shape == (6,)
