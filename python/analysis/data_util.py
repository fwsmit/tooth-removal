import numpy as np

def filter_extraction(data, upper, tooth):
    res = []
    for extraction in data:
        q = extraction["quadrant"]
        t = extraction["tooth"]
        if (q >= 3 and upper) or (q <= 2 and not upper):
            if tooth == t:
                res.append(extraction)
    return res

def get_values(data, key):
    res = []
    for e in data:
        res.append(e[key])

    return res

def get_std_val(data, key):
    return np.std(get_values(data,key))

def get_avg_val(data, key):
    return np.average(get_values(data,key))

def filter_complications(data):
    res = []
    for extraction in data:
        complications = ["forceps_slipped", "element_fractured", "epoxy_failed", "nonrepresentative"]
        valid = True
        for c in complications:
            if c in extraction and extraction[c]:
                print("Skipping extraction", extraction["quadrant"], extraction["tooth"])
                valid = False
                break
        if valid:
            res.append(extraction)

    return res

def filter_people(data, person_type):
    res = []
    for extraction in data:
        if extraction["person_type"] in person_type:
            res.append(extraction)

    return res
