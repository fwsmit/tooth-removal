import os
import argparse
import platform
import glob



from xdg_base_dirs import xdg_data_home
from logging import warning

from fix_data import fix_data_cutoff
from index import update_index
from graphs import *
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
parser.add_argument('--graph_frequencies', required=False, action='store_true', help="Graph the fourier transform of the absolute force and torque")
parser.add_argument('--graph_force_torque', required=False, action='store_true', help="Graph the force and torque in all direction")
parser.add_argument('--complete_analysis', required=False, action='store_true', help="Perform a complete analysis of the data. It can be presented in a number of different ways")
parser.add_argument('--generate_ft_plots', required=False, action='store_true', help="Generate force-torque plots for all extractions in user://Analysis_data (or directory specified with --dir) ")
parser.add_argument('--dir', required=False, action='store', help="Specify directory to use for complete analysis or generating ft plots")
parser.add_argument('--per_teeth', required=False, action = 'store_true', help="Show complete analysis per tooth")
parser.add_argument('--tooth', required=False, action = 'store', help="Show complete analysis for a single tooth")
parser.add_argument('--jaw', required=False, action = 'store', help="Specify which jaw to show the complete analysis for (upper or lower). Use in combination with --grouped or --tooth")
parser.add_argument('--grouped', required=False, action = 'store_true', help="Show complete analysis per tooth group")
parser.add_argument('--person_type', required=False, action = 'store', help="Filter extractions by person type (Student, Kaakchirurg in opleiding, Tandarts, Kaakchirurg or Demo)")
args = parser.parse_args()

possible_files = []

if args.complete_analysis or args.generate_ft_plots:
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
    if args.per_teeth:
        analysis = complete_analysis(possible_files, dataDir, args.person_type)
        plot_analysis(analysis, True, None, None, None)
    else:
        if args.jaw == 'upper':
            upper_lower = True
        elif args.jaw == 'lower':
            upper_lower = False
        else:
            print("Please specify which jaw with --jaw [upper/lower]")
            exit(1)
    
        analysis = complete_analysis(possible_files, dataDir, args.person_type)
        if args.grouped:
            plot_analysis_grouped(analysis, upper_lower)
        else:    
            tooth = int(args.tooth)
            plot_analysis(analysis, False, None, tooth, upper_lower)

if args.generate_ft_plots:
    generate_ft_plots(possible_files, dataDir)

fileIndex = 0
chosenFile = possible_files[fileIndex]

if args.filename is not None:
    chosenFile = args.filename

if args.graph_frequencies:
    graph_freqencies(chosenFile, dataDir)

if args.graph_force_torque:
    graph_ft(chosenFile, dataDir)
