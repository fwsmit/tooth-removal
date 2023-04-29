import os
import json
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

def plot_vectors(axis, vectors):
    x = range(len(vectors))
    x_smooth = np.linspace(0, len(vectors)-1, 300)  
    cs = CubicSpline(x, vectors)
    axis.plot(x_smooth, cs(x_smooth))

def show_file_stats(filename):
    filepath = os.path.join(dataDir, filename)
    with open(filepath) as f:
        propDic = json.load(f)
    print("Duration:", round(propDic["end_timestamp"] - propDic["start_timestamp"]), "seconds")
    force_x, force_y, force_z = split_vectors(propDic["corrected_forces"])
    torque_x, torque_y, torque_z = split_vectors(propDic["corrected_torques"])
    fig, ax = plt.subplots(2,3)
    plot_vectors(ax[0][0], force_x)
    plot_vectors(ax[0][1], force_y)
    plot_vectors(ax[0][2], force_z)
    plot_vectors(ax[1][0], torque_x)
    plot_vectors(ax[1][1], torque_y)
    plot_vectors(ax[1][2], torque_z)
    plt.show()
    #print(forces)

fileIndex = 4

possible_files = []
for filename in os.listdir(dataDir):
    if filename.startswith("extraction_data"):
        possible_files.append(filename)

show_file_stats(possible_files[fileIndex])
