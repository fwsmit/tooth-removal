import os
from json_parse import *

def update_index(possible_files, dataDir):
    index_filepath = os.path.join(dataDir, "index.json")
    index_dic = {}
    if os.path.isfile(index_filepath):
        index_dic = parse_json("index.json", dataDir)
    index_changed = False

    # Add new files
    for f in possible_files:
        if f in index_dic:
            continue
        index_changed = True
        dic = parse_json(f, dataDir)
        for i in ["", "_x", "_y", "_z"]:
            dic.pop("corrected_forces"+i, None)
            dic.pop("corrected_torques"+i, None)
            dic.pop("raw_forces"+i, None)
            dic.pop("raw_torques"+i, None)
        dic.pop("buccal/lingual")
        dic.pop("mesial/distal")
        dic.pop("extrusion/intrusion")
        dic.pop("mesial/distal angulation")
        dic.pop("bucco/linguoversion")
        dic.pop("mesiobuccal/lingual")
        index_dic[f] = dic
        print("Added file", f)

    # Remove deleted files
    for f in list(index_dic):
        filepath = os.path.join(dataDir, f)
        if not os.path.isfile(filepath):
            index_dic.pop(f)
            print("Removed file", f)
            index_changed = True

    if index_changed:
        print("Writing new index")
        with open(index_filepath, 'w') as f:
            json.dump(index_dic, f, indent="\t")
    else:
        print("Nothing has changed")
