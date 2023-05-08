import os
import json
import argparse
import matplotlib.pyplot as plt
from xdg_base_dirs import xdg_data_home
from scipy.interpolate import CubicSpline
from scipy.ndimage import uniform_filter1d
from scipy.signal import find_peaks
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

def norm_vectors(vectors):
    res = []
    for v in vectors:
        res.append(np.linalg.norm(v))
    return res

def merge_vectors(x, y, z):
    return np.column_stack([x,y,z])

# Return length of all vectors in array
def vectors_mag(vectors):
    mags = []
    for v in vectors:
        mags.append(np.linalg.norm(v))

    return mags

def find_start_end_from_vec(vec, threshold):
    abs_vec = vectors_mag(vec) 

    # Find moving average
    filter_size = 10
    filtered = uniform_filter1d(abs_vec, filter_size)
    
    greater = np.argwhere(filtered > threshold)

    return greater[0], greater[-1]

def find_starting_point(force, torque):
    force_start, force_end = find_start_end_from_vec(force, 1)
    torque_start, torque_end = find_start_end_from_vec(torque, 0.2)
    return (force_start + torque_start)/2, (force_end + torque_end) / 2

def fix_vector(vectors, duration):
    num_samples_per_second = 1000 # sample frequency of sensor
    num_samples = round(duration * num_samples_per_second)
    return vectors[-num_samples:]

def get_smoothened_line(vectors, n_points):
    x = range(len(vectors))
    x_smooth = np.linspace(0, len(vectors)-1, n_points)
    cs = CubicSpline(x, vectors)
    return x_smooth, cs

def analyze_peaks(vectors):
    peak_width_min = 100
    prominence_min = 0.25
    peaks, properties = find_peaks(vectors, width=peak_width_min, prominence=prominence_min)
    return peaks

def plot_vectors(axis, vectors, _title, duration, points=None):
    n_points = 300
    x_smooth, cs = get_smoothened_line(vectors, n_points)
    timelabel = np.linspace(0, duration, n_points)  

    #axis.plot(timelabel, cs(x_smooth), label=_title)
    axis.plot(vectors)

    if points:
        for p in points:
            t = p / len(vectors) * duration
            axis.plot(p, cs(p), marker="o")

def parse_json(filename):
    filepath = os.path.join(dataDir, filename)
    with open(filepath) as f:
        return json.load(f)

def get_forces(dic):
    return dic["corrected_forces_x"], dic["corrected_forces_y"], dic["corrected_forces_z"]

def get_torques(dic):
    return dic["corrected_torques_x"], dic["corrected_torques_y"], dic["corrected_torques_z"]

def show_file_stats(filename):
    propDic = parse_json(filename)
    duration = propDic["end_timestamp"] - propDic["start_timestamp"]
    print("Duration:", round(duration), "seconds")
    print("Tooth:", propDic["tooth"])
    force_x, force_y, force_z = get_forces(propDic)
    torque_x, torque_y, torque_z = get_torques(propDic)

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
    fig, ax = plt.subplots(2,4, sharex='col', sharey='row')

    forces = merge_vectors(force_x, force_y, force_z)
    forces_norm = norm_vectors(forces)
    torques = merge_vectors(torque_x, torque_y, torque_z)
    torques_norm = norm_vectors(torques)

    arguments = [
            [ax[0][0], force_x, "Force (x)", True],
            [ax[0][1], force_y, "Force (y)", True],
            [ax[0][2], force_z, "Force (z)", True],
            [ax[1][0], torque_x, "Torque (x)", False],
            [ax[1][1], torque_y, "Torque (y)", False],
            [ax[1][2], torque_z, "Torque (z)", False],
            [ax[1][3], torques_norm, "Torque absolute", False],
            [ax[0][3], forces_norm, "Force absolute", True],
            ]
    ax[0][0].set_ylabel("Force (N)")
    ax[1][0].set_ylabel("Torque (Nm)")
    for a in ax[1]:
        a.set_xlabel("Time (s)")

    start, end = find_starting_point(forces, torques)
    points = [start, end]
    force_peaks = analyze_peaks(forces_norm)
    force_points = []
    force_points.extend(points)
    force_points.extend(force_peaks)
    torque_peaks = analyze_peaks(torques_norm)
    torque_points = []
    torque_points.extend(points)
    torque_points.extend(torque_peaks)

    for a in arguments:
        isForce = a[3]
        if isForce:
            p = force_points
        else:
            p = torque_points
        plot_vectors(a[0], a[1], a[2], duration, p)
        a[0].title.set_text(a[2])
    fig.tight_layout()
    plt.show()

def fix_data_vector(dic, duration, name):
    vectors = list(split_vectors(dic[name]))
    if len(vectors[0])/duration > 1000:
        for i in range(len(vectors)):
            vectors[i] = fix_vector(vectors[i], duration)

    appedices = ["_x", "_y", "_z"]
    for v, a in zip(vectors, appedices):
        dic[name+a] = v

def fix_data_cutoff(filename):
    propDic = parse_json(filename)
    duration = propDic["end_timestamp"] - propDic["start_timestamp"]

    # Fix data collection error because of bug #24
    print("Fixing vectors of", filename)
    for name in ["corrected_forces", "corrected_torques", "raw_forces", "raw_torques"]:
        fix_data_vector(propDic, duration, name)
        propDic.pop(name, None)

    filepath = os.path.join(dataDir, filename)
    with open(filepath, 'w') as f:
        json.dump(propDic, f, indent="\t")


parser = argparse.ArgumentParser(description='Show graphs of sensor data')
parser.add_argument('filename', nargs="?", help='Path to data file. This file must be in JSON format')
parser.add_argument('--update_index', required=False, action='store_true', help='Update index of all data files')
parser.add_argument('--fix_data', required=False, action='store_true')
parser.add_argument('--disable_graph', required=False, action='store_true')

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

if args.fix_data:
    for f in possible_files:
        fix_data_cutoff(f)

if args.filename is not None:
    show_file_stats(args.filename)
    exit(0)

fileIndex = 4

if not args.disable_graph:
    show_file_stats(possible_files[fileIndex])
