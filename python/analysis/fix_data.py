import os

from json_parse import *
from vec_util import *

def fix_vector(vectors, duration):
    num_samples_per_second = 1000 # sample frequency of sensor
    num_samples = round(duration * num_samples_per_second)
    return vectors[-num_samples:]

def fix_data_vector(dic, duration, name):
    vectors = list(split_vectors(dic[name]))
    if len(vectors[0])/duration > 1000:
        for i in range(len(vectors)):
            vectors[i] = fix_vector(vectors[i], duration)

    appedices = ["_x", "_y", "_z"]
    for v, a in zip(vectors, appedices):
        dic[name+a] = v

def fix_data_cutoff(filename, dataDir):
    propDic = parse_json(filename, dataDir)
    duration = propDic["end_timestamp"] - propDic["start_timestamp"]

    # Fix data collection error because of bug #24
    print("Fixing vectors of", filename)
    for name in ["corrected_forces", "corrected_torques", "raw_forces", "raw_torques"]:
        fix_data_vector(propDic, duration, name)
        propDic.pop(name, None)

    filepath = os.path.join(dataDir, filename)
    with open(filepath, 'w') as f:
        json.dump(propDic, f, indent="\t")
