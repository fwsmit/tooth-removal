import json
import os

def parse_json(filename, dataDir):
    filepath = os.path.join(dataDir, filename)
    if not os.path.isfile(filepath):
        return {}
    with open(filepath) as f:
        return json.load(f)
