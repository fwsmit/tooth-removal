import os
import json
from xdg_base_dirs import xdg_data_home

dataDir = os.path.join(xdg_data_home(),"godot", "app_userdata", "Tooth removal")

def show_file_stats(filename):
    filepath = os.path.join(dataDir, filename)
    with open(filepath) as f:
        propDic = json.load(f)
    print(propDic)

fileIndex = 0

possible_files = []
for filename in os.listdir(dataDir):
    if filename.startswith("extraction_data"):
        possible_files.append(filename)

show_file_stats(possible_files[fileIndex])
