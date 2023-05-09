import os
import argparse
from xdg_base_dirs import xdg_data_home

from fix_data import fix_data_cutoff
from index import update_index
from graphs import graph_ft, graph_freqencies


dataDir = os.path.join(xdg_data_home(),"godot", "app_userdata", "Tooth removal")

parser = argparse.ArgumentParser(description='Show graphs of sensor data')
parser.add_argument('filename', nargs="?", help='Path to data file. This file must be in JSON format')
parser.add_argument('--update_index', required=False, action='store_true', help='Update index of all data files')
parser.add_argument('--fix_data', required=False, action='store_true')
parser.add_argument('--graph_frequencies', required=False, action='store_true')
parser.add_argument('--graph_force_torque', required=False, action='store_true')
parser.add_argument('--complete_analysis', required=False, action='store_true')

args = parser.parse_args()

possible_files = []
for filename in os.listdir(dataDir):
    if filename.startswith("extraction_data"):
        possible_files.append(filename)

if args.update_index:
    print("Updating index")
    update_index(possible_files, dataDir)
    exit(0)

if args.fix_data:
    for f in possible_files:
        fix_data_cutoff(f, dataDir)

fileIndex = 4
chosenFile = possible_files[fileIndex]

if args.filename is not None:
    chosenFile = args.filename

if args.graph_frequencies:
    graph_freqencies(chosenFile, dataDir)

if args.graph_force_torque:
    graph_ft(chosenFile, dataDir)
