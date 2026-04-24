import pytest
from nbs_bl.plans.scans import nbs_count, nbs_energy_scan

def test_nbs_count(RE, db):
    print("Running nbs_count test...")
    RE(nbs_count(10, dwell=1.0))
    print("nbs_count test completed")
    run = db[-1]
    assert run.start['plan_name'] == "nbs_count"
    assert run.primary['data']['time'].shape == (10,)

def test_nbs_energy_scan(RE, db):
    print("Running nbs_energy_scan test...")
    RE(nbs_energy_scan(700, 1.0, 705, dwell=1.0))
    run = db[-1]
    assert run.primary['data']['time'].shape == (6,)