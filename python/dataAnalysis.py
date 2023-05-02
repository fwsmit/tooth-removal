import os
import json
import argparse
import matplotlib.pyplot as plt
from xdg_base_dirs import xdg_data_home
from scipy.interpolate import CubicSpline
from scipy.ndimage import uniform_filter1d
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

def merge_vectors(x, y, z):
    return np.concatenate([x,y,z], axis=0)

# Return length of all vectors in array
def vectors_mag(vectors):
    mags = []
    for v in vectors:
        mags.append(np.linalg.norm(v))

    return mags

def find_starting_point(force, torque):
    abs_force = vectors_mag(force) 
    abs_torque = vectors_mag(torque) 

    # Find moving average
    filter_size = 10
    f_filt = uniform_filter1d(abs_force, filter_size)
    t_filt = uniform_filter1d(abs_torque, filter_size)
    
    f_tresh = 1
    t_tresh = 0.2

    i_f = np.argwhere(f_filt > f_tresh)[0]
    i_t = np.argwhere(t_filt > t_tresh)[0]
    return (i_f + i_t)/2

def fix_vector(vectors, duration):
    num_samples_per_second = 990 # rough guess
    num_samples = round(duration * num_samples_per_second)
    return vectors[-num_samples:]

def plot_vectors(axis, vectors, _title, duration, points=None):
    x = range(len(vectors))
    n_points = 300
    x_smooth = np.linspace(0, len(vectors)-1, n_points)

    timelabel = np.linspace(0, duration, n_points)  
    cs = CubicSpline(x, vectors)

    axis.plot(timelabel, cs(x_smooth), label=_title)

    if points:
        for p in points:
            t = p / len(vectors) * duration
            axis.plot(t, cs(p), marker="o")

def parse_json(filename):
    filepath = os.path.join(dataDir, filename)
    with open(filepath) as f:
        return json.load(f)

def show_file_stats(filename):
    propDic = parse_json(filename)
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

    forces = merge_vectors(force_x, force_y, force_z)
    torques = merge_vectors(torque_x, torque_y, torque_z)

    arguments = [
            [ax[0][0],force_x, "Force (x)"],
            [ax[0][1],force_y, "Force (y)"],
            [ax[0][2],force_z, "Force (z)"],
            [ax[1][0],torque_x, "Torque (x)"],
            [ax[1][1],torque_y, "Torque (y)"],
            [ax[1][2],torque_z, "Torque (z)"],
            ]
    ax[0][0].set_ylabel("Force (N)")
    ax[1][0].set_ylabel("Torque (Nm)")
    for a in ax[1]:
        a.set_xlabel("Time (s)")

    start = find_starting_point(forces, torques)

    for a in arguments:
        plot_vectors(a[0], a[1], a[2], duration, [start])
        a[0].title.set_text(a[2])
    fig.tight_layout()
    plt.show()


parser = argparse.ArgumentParser(description='Show graphs of sensor data')
parser.add_argument('filename', nargs="?", help='Path to data file. This file must be in JSON format')
parser.add_argument('--update_index', required=False, action='store_true', help='Update index of all data files')

args = parser.parse_args()

possible_files = []
for filename in os.listdir(dataDir):
    if filename.startswith("extraction_data"):
        possible_files.append(filename)

if args.update_index:
    print("Updating index")
    index_filepath = os.path.join(dataDir, "index.json")
    index_dic = parse_json("index.json")
    index_changed = False

    # Add new files
    for f in possible_files:
        if f in index_dic:
            continue
        index_changed = True
        dic = parse_json(f)
        for i in ["", "_x", "_y", "_z"]:
            dic.pop("corrected_forces"+i, None)
            dic.pop("corrected_torques"+i, None)
            dic.pop("raw_forces"+i, None)
            dic.pop("raw_torques"+i, None)
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
    exit(0)

if args.filename is not None:
    show_file_stats(args.filename)
    exit(0)

fileIndex = 4

show_file_stats(possible_files[fileIndex])
