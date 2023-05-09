import json
import os

def parse_json(filename, dataDir):
    filepath = os.path.join(dataDir, filename)
    with open(filepath) as f:
        return json.load(f)
