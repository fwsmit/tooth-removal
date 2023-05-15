import json
import os
from logging import warning

def parse_json(filename, dataDir):
    filepath = os.path.join(dataDir, filename)
    if not os.path.isfile(filepath):
        warning("File {} does not exist".format(filename))
        exit(1)
    with open(filepath) as f:
        return json.load(f)
