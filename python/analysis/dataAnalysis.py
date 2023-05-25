import os
import argparse
import platform
import glob

from xdg_base_dirs import xdg_data_home
from logging import warning

from fix_data import fix_data_cutoff
from index import update_index
from graphs import graph_ft, graph_freqencies, plot_analysis
from analysis import complete_analysis

def get_data_dir():
    if platform.system() == 'Windows':
        # Modify this path according to your desired location on Windows
        return os.path.join(os.getenv('APPDATA'), 'Godot', 'app_userdata', 'Tooth removal')
    else:
        # For Unix-like systems, use xdg_data_home
        return os.path.join(xdg_data_home(), 'godot', 'app_userdata', 'Tooth removal')

dataDir = get_data_dir()


parser = argparse.ArgumentParser(description='Show graphs of sensor data')
parser.add_argument('filename', nargs="?", help='Path to data file. This file must be in JSON format')
parser.add_argument('--update_index', required=False, action='store_true', help='Update index of all data files')
parser.add_argument('--fix_data', required=False, action='store_true')
parser.add_argument('--graph_frequencies', required=False, action='store_true')
parser.add_argument('--graph_force_torque', required=False, action='store_true')
parser.add_argument('--complete_analysis', required=False, action='store_true')
parser.add_argument('--dir', required=False, action='store')
parser.add_argument('--per_teeth', required=False, action = 'store_true')
parser.add_argument('--tooth', required=False, action = 'store')
parser.add_argument('--jaw', required=False, action = 'store')
args = parser.parse_args()


if args.jaw == 'upper':
    upper_lower = True
    
if args.jaw == 'lower':
    upper_lower = False
    
possible_files = []

if args.complete_analysis:
    if args.dir:
        dir = args.dir
    else:
        dir = "Analysis_data"
    p = os.path.join(dataDir, dir)
    possible_files = glob.glob(p + '/**/extraction_data*.json', recursive=True)
else:
    for filename in os.listdir(dataDir):
        if filename.startswith("extraction_data"):
            possible_files.append(filename)

if len(possible_files) == 0:
    warning("No files found. Aborting")
    exit(1)

if args.update_index:
    print("Updating index")
    update_index(possible_files, dataDir)
    exit(0)

if args.fix_data:
    for f in possible_files:
        fix_data_cutoff(f, dataDir)

if args.complete_analysis:
    analysis = complete_analysis(possible_files, dataDir)
    if args.per_teeth:
        plot_analysis(analysis, True, None, None)
    else:
        tooth = int(args.tooth)
        plot_analysis(analysis, False, tooth, upper_lower)

fileIndex = 0
chosenFile = possible_files[fileIndex]

if args.filename is not None:
    chosenFile = args.filename

if args.graph_frequencies:
    graph_freqencies(chosenFile, dataDir)

if args.graph_force_torque:
    graph_ft(chosenFile, dataDir)
