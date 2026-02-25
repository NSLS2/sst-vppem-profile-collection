from nslsii import configure_kafka_publisher, configure_bluesky_logging, configure_ipython_logging
from nslsii.common.ipynb.logutils import log_exception
from bluesky_queueserver import is_re_worker_active

from nbs_bl.configuration import load_and_configure_everything
from nbs_bl.beamline import GLOBAL_BEAMLINE
from tiled.client import from_profile
import time as ttime
import os


load_and_configure_everything()
RE = GLOBAL_BEAMLINE.RunEngine
ipython = get_ipython()

configure_bluesky_logging(ipython=ipython)

# IPython logging will be enabled with logstart(...)
configure_ipython_logging(exception_logger=log_exception, ipython=ipython)

ipython.run_line_magic("xmode", "minimal")

#tiled_writing_client = from_profile("nsls2", api_key=os.environ["TILED_BLUESKY_WRITING_API_KEY_NEXAFS"])['ucal']['raw']
#c = tiled_reading_client = from_profile("nsls2")["ucal"]["raw"]

def post_document(name, doc):
    ATTEMPTS = 20
    error = None
    for attempt in range(ATTEMPTS):
        try:
            tiled_writing_client.post_document(name, doc)
        except Exception as e:
            print(f"Document saving failure: {e!r}")
            error = e
        else:
            break
        ttime.sleep(2)
    else:
        raise error

# RE.subscribe(post_document)
configure_kafka_publisher(RE, beamline_name="vppem")

if is_re_worker_active():
    RE.waiting_hook = None

