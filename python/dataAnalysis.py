import os
import json
import argparse
import matplotlib.pyplot as plt
from xdg_base_dirs import xdg_data_home
from scipy.interpolate import CubicSpline
import matplotlib
import numpy as np

dataDir = os.path.join(xdg_data_home(),"godot", "app_userdata", "Tooth removal")

def split_vectors(forces):
    xs = []
    ys = []
    zs = []
    for f in forces:
        f_s = f[1:-1].split(",")
        xs.append(float(f_s[0]))
        ys.append(float(f_s[1]))
        zs.append(float(f_s[2]))
    return xs, ys, zs

def fix_vector(vectors, duration):
    num_samples_per_second = 990 # rough guess
    num_samples = round(duration * num_samples_per_second)
    return vectors[-num_samples:]

def plot_vectors(axis, vectors, _title):
    x = range(len(vectors))
    x_smooth = np.linspace(0, len(vectors)-1, 300)  
    cs = CubicSpline(x, vectors)
    axis.plot(x_smooth, cs(x_smooth), label=_title)

def show_file_stats(filename):
    filepath = os.path.join(dataDir, filename)
    with open(filepath) as f:
        propDic = json.load(f)
    duration = propDic["end_timestamp"] - propDic["start_timestamp"]
    print("Duration:", round(duration), "seconds")
    force_x, force_y, force_z = split_vectors(propDic["corrected_forces"])
    torque_x, torque_y, torque_z = split_vectors(propDic["corrected_torques"])

    # Fix data collection error because of bug #24
    if len(force_x)/duration > 1000:
        print("Fixing vectors")
        # for v in [force_x, force_y, force_z, torque_x, torque_y, torque_z]:
        force_x = fix_vector(force_x, duration)
        force_y = fix_vector(force_y, duration)
        force_z = fix_vector(force_z, duration)
        torque_x = fix_vector(torque_x, duration)
        torque_y = fix_vector(torque_y, duration)
        torque_z = fix_vector(torque_z, duration)
    fig, ax = plt.subplots(2,3, sharex='col', sharey='row')
    fig.tight_layout()

    arguments = [
            [ax[0][0],force_x, "Force (x)"],
            [ax[0][1],force_y, "Force (y)"],
            [ax[0][2],force_z, "Force (z)"],
            [ax[1][0],torque_x, "Torque (x)"],
            [ax[1][1],torque_y, "Torque (y)"],
            [ax[1][2],torque_z, "Torque (z)"],
            ]

    for a in arguments:
        plot_vectors(a[0], a[1], a[2])
        a[0].title.set_text(a[2])
    plt.show()


parser = argparse.ArgumentParser(description='Show graphs of sensor data')
parser.add_argument('filename', nargs="?", help='Path to data file. This file must be in JSON format')

args = parser.parse_args()

if args.filename is not None:
    show_file_stats(args.filename)
    exit(0)

fileIndex = 2

possible_files = []
for filename in os.listdir(dataDir):
    if filename.startswith("extraction_data"):
        possible_files.append(filename)

show_file_stats(possible_files[fileIndex])
