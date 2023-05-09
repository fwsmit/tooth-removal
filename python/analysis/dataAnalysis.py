import os
import argparse
import matplotlib.pyplot as plt
from xdg_base_dirs import xdg_data_home
from scipy.ndimage import uniform_filter1d
from scipy.signal import find_peaks, butter, lfilter
from scipy.fft import fft, fftfreq
import matplotlib
import numpy as np

from vec_util import *
from fix_data import *
from json_parse import *

dataDir = os.path.join(xdg_data_home(),"godot", "app_userdata", "Tooth removal")

def find_start_end_from_vec(vec, threshold):
    abs_vec = vectors_mag(vec) 

    # Find moving average
    filter_size = 1
    filtered = uniform_filter1d(abs_vec, filter_size)
    
    greater = np.argwhere(filtered > threshold)

    return greater[0][0], greater[-1][0]

def find_starting_point(force, torque):
    force_start, force_end = find_start_end_from_vec(force, 1)
    torque_start, torque_end = find_start_end_from_vec(torque, 0.2)
    start = (force_start + torque_start)/2
    end = (force_end + torque_end) / 2
    return start, end

def analyze_peaks(vectors):
    peak_width_min = 100
    prominence_min = 0.25
    peaks, properties = find_peaks(vectors, width=peak_width_min, prominence=prominence_min)
    return peaks

def plot_vectors(axis, vectors, _title, duration, points=None):
    n_points = len(vectors)
    timelabel = np.linspace(0, duration, n_points)  

    axis.plot(timelabel, vectors, label=_title)

    if points:
        for p in points:
            t = p / len(vectors) * duration
            axis.plot(t, vectors[round(p)], marker="o")

def get_forces(dic):
    return [dic["corrected_forces_x"], dic["corrected_forces_y"], dic["corrected_forces_z"]]

def get_torques(dic):
    return [dic["corrected_torques_x"], dic["corrected_torques_y"], dic["corrected_torques_z"]]

def plot_frequencies(ax, vec, name):
    # Number of samplepoints
    N = len(vec)
    # sample spacing
    T = 1.0 / 1000
    x = np.linspace(0.0, N*T, N)
    y = vec
    yf = fft(y)
    yf[0] = 0
    xf = np.linspace(0.0, 1.0/(2.0*T), N//2)

    ax.plot(xf, 2.0/N * np.abs(yf[:N//2]))

def butter_lowpass(cutoff, fs, order=5):
    return butter(order, cutoff, fs=fs, btype='lowpass', analog=False)

def lowpass_filter(vec, cutoff, fs=1000, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, vec)
    return y

def get_direction_changes(v, peaks):
    count = 0
    sign = 0

    for p in peaks:
        y = v[round(p)]
        if sign != np.sign(y):
            count += 1
            sign = np.sign(y)

    return count

def show_file_stats(filename, show_frequencies):
    propDic = parse_json(filename, dataDir)
    duration = propDic["end_timestamp"] - propDic["start_timestamp"]
    print("Duration:", round(duration), "seconds")
    print("Tooth:", propDic["tooth"])
    forces = get_forces(propDic)
    torques = get_torques(propDic)

    cutoff = 3
    for i in range(len(forces)):
        forces[i] = lowpass_filter(forces[i], cutoff)
        torques[i] = lowpass_filter(torques[i], cutoff)

    forces_norm = norm_vectors(forces)
    torques_norm = norm_vectors(torques)
    if show_frequencies:
        # Show frequencies
        fig, ax = plt.subplots(1,2)
        arguments = [
                [ax[0], forces_norm, "Force frequencies"],
                [ax[1], torques_norm, "Torque frequencies"],
                ]

        for a in arguments:
            plot_frequencies(a[0], a[1], a[2])
    else:
        fig, ax = plt.subplots(2,4, sharex='col', sharey='row')
        arguments = [
                [ax[0][0], forces[0], "Force (x)", True],
                [ax[0][1], forces[1], "Force (y)", True],
                [ax[0][2], forces[2], "Force (z)", True],
                [ax[1][0], torques[0], "Torque (x)", False],
                [ax[1][1], torques[1], "Torque (y)", False],
                [ax[1][2], torques[2], "Torque (z)", False],
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

        f_direction_changes = []
        t_direction_changes = []
        # find number of direction changes
        for i in range(len(forces)):
            f_direction_changes.append(get_direction_changes(forces[i], force_peaks))
            t_direction_changes.append(get_direction_changes(torques[i], torque_peaks))

        print("Direction changes (force):", f_direction_changes)
        print("Direction changes (torque)", t_direction_changes)

        for a in arguments:
            isForce = a[3]
            if isForce:
                p = force_points
            else:
                p = torque_points
            plot_vectors(a[0], a[1], a[2], duration, p)
            a[0].title.set_text(a[2])

    # Show plots
    fig.tight_layout()
    plt.show()
    

parser = argparse.ArgumentParser(description='Show graphs of sensor data')
parser.add_argument('filename', nargs="?", help='Path to data file. This file must be in JSON format')
parser.add_argument('--update_index', required=False, action='store_true', help='Update index of all data files')
parser.add_argument('--fix_data', required=False, action='store_true')
parser.add_argument('--disable_graph', required=False, action='store_true')
parser.add_argument('--show_frequencies', required=False, action='store_true')

args = parser.parse_args()

possible_files = []
for filename in os.listdir(dataDir):
    if filename.startswith("extraction_data"):
        possible_files.append(filename)

if args.update_index:
    print("Updating index")
    index_filepath = os.path.join(dataDir, "index.json")
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
        fix_data_cutoff(f, dataDir)

if args.filename is not None:
    show_file_stats(args.filename)
    exit(0)

fileIndex = 4

if not args.disable_graph:
    show_file_stats(possible_files[fileIndex], args.show_frequencies)
