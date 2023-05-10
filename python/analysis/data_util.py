
def filter_extraction(data, upper, tooth):
    res = []
    for extraction in data:
        q = extraction["quadrant"]
        t = extraction["tooth"]
        if (q >= 3 and upper) or (q <= 2 and not upper):
            if tooth == t:
                res.append(extraction)
    return res

def get_avg_val(data, key):
    total = 0
    for e in data:
        total += e[key]

    return total / len(data)

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

