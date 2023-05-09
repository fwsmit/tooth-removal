import matplotlib
import matplotlib.pyplot as plt

from json_parse import *
from vec_util import *
from analysis import *

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

def plot_vectors(axis, vectors, _title, duration, points=None):
    n_points = len(vectors)
    timelabel = np.linspace(0, duration, n_points)  

    axis.plot(timelabel, vectors, label=_title)

    if points:
        for p in points:
            t = p / len(vectors) * duration
            axis.plot(t, vectors[round(p)], marker="o")

def graph_freqencies():
    forces_norm = norm_vectors(forces)
    torques_norm = norm_vectors(torques)
    # Show frequencies
    fig, ax = plt.subplots(1,2)
    arguments = [
            [ax[0], forces_norm, "Force frequencies"],
            [ax[1], torques_norm, "Torque frequencies"],
            ]

    for a in arguments:
        plot_frequencies(a[0], a[1], a[2])
    return fig

def graph_ft(forces, torques, duration):
    forces_norm = norm_vectors(forces)
    torques_norm = norm_vectors(torques)
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
    return fig

def show_file_stats(filename, show_frequencies, dataDir):
    propDic = parse_json(filename, dataDir)
    duration = propDic["end_timestamp"] - propDic["start_timestamp"]
    print("Duration:", round(duration), "seconds")
    print("Quadrant:", propDic["quadrant"])
    print("Tooth:", propDic["tooth"])
    forces = get_forces(propDic)
    torques = get_torques(propDic)

    cutoff = 3
    for i in range(len(forces)):
        forces[i] = lowpass_filter(forces[i], cutoff)
        torques[i] = lowpass_filter(torques[i], cutoff)

    print(get_parameters(forces, torques))

    if show_frequencies:
        fig = graph_freqencies()
    else:
        fig = graph_ft(forces, torques, duration)

    # Show plots
    fig.tight_layout()
    plt.show()
