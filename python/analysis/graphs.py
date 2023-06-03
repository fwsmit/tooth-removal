import matplotlib
import matplotlib.pyplot as plt

from json_parse import *
from vec_util import *
from analysis import *
from data_util import *

fig = None

t_range = range(1,9)

directions = [{'Buccal':['fx_', '_pos'], 'Lingual':['fx_', '_neg'],
                  'Mesial':['fy_', '_pos'], 'Distal':['fy_', '_neg'],
                  'Extrusion':['fz_', '_pos'], 'Intrusion':['fz_', '_neg']},
                  {'Mesial angulation':['tx_', '_pos'], 'Distal angulation':['tx_', '_neg'],
                  'Buccoversion':['ty_', '_pos'], 'Linguoversion':['ty_', '_neg'],
                  'Mesiobuccal angulation':['tz_', '_pos'], 'Mesiolingual angulation':['tz_', '_neg']}]

groups = {'incisors': [1, 2], 'canines': [3], 'premolars': [4,5], 'molars': [6, 7, 8]}

def show_plots(fig):
    fig.tight_layout()
    plt.show()

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

def graph_freqencies(filename, dataDir):
    propDic = parse_json(filename, dataDir)

    # Skip empty files
    forces = get_forces(propDic)
    torques = get_torques(propDic)
    if len(forces) == 0 or len(forces[0]) == 0:
        print("Empty file, skipping", filename)
        return

    forces = get_forces(propDic)
    torques = get_torques(propDic)

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

    show_plots(fig)

def store_plot(fig, filename, dataDir):
    plot_filename = os.path.basename(filename).removesuffix(".json") + ".png"
    plot_filepath = os.path.join(dataDir, "ft-plots", plot_filename)
    fig.set_size_inches(10, 6) # Make sure labels don't overlap
    fig.savefig(plot_filepath)
    plt.close(fig)

def graph_ft(filename, dataDir, interactive=True):
    propDic = parse_json(filename, dataDir)

    # Skip empty files
    forces = get_forces(propDic)
    torques = get_torques(propDic)
    if len(forces) == 0 or len(forces[0]) == 0:
        print("Empty file, skipping", filename)
        return

    duration = propDic["end_timestamp"] - propDic["start_timestamp"]
    print("Duration:", round(duration), "seconds")
    print("Quadrant:", propDic["quadrant"])
    print("Tooth:", propDic["tooth"])
    forces = get_forces(propDic)
    torques = get_torques(propDic)
    person_type = propDic["person_type"]
    tooth = propDic["tooth"]
    quadrant = propDic["quadrant"]

    forces,torques = lowpass_filter_all(forces, torques)

    forces_norm = norm_vectors(forces)
    torques_norm = norm_vectors(torques)

    fig, ax = plt.subplots(2,4, sharex='col', sharey='row')
    fig.suptitle("Extraction of tooth " + str(quadrant) + str(tooth) + " (" + person_type.lower() + ")")
    arguments = [
            [ax[0][0], forces[0], "Buccal/lingual", True],
            [ax[0][1], forces[1], "Mesial/distal", True],
            [ax[0][2], forces[2], "Extrusion/intrusion", True],
            [ax[1][0], torques[0], "Mesial/distal angulation", False],
            [ax[1][1], torques[1], "Bucco/linguoversion", False],
            [ax[1][2], torques[2], "Mesiobuccal/lingual", False],
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

    if interactive:
        show_plots(fig)
    else:
        store_plot(fig, filename, dataDir)

def plot_bar_per_teeth(data, main_key):
    vals = []
    labels = []
    errors = []
    
    if main_key == "direction_changes":
            key = main_key
    else:
        key = 'fmag_' + main_key
    
    upper_lower = [False, True]
    for ul in upper_lower:
        if ul:
            t_range = reversed(t_range)
        for t in t_range:
            matching_extractions = filter_extraction(data, ul, t)
            vals.append(get_avg_val(matching_extractions, key))
            errors.append(get_std_val(matching_extractions, key))
            l = ""
            if ul:
                l += "U"
            else:
                l += "L"
            l += str(t)
            l += " (n = {})".format(len(matching_extractions))
            labels.append(l)
    return vals, labels, errors



def plot_bar_per_direction(data, matching_extractions, main_key, label, teeth, upper_lower):   
    vals = []
    labels = []
    errors = []
    
    matching_extractions = filter_extraction(data, upper_lower, teeth)
    
    if label == "Force auc [Ns]":
        for direction in directions[0]:
            key = directions[0][direction][0] + main_key + directions[0][direction][-1]
            if get_avg_val(matching_extractions, key) >= 0:
                vals.append(get_avg_val(matching_extractions, key))
            else:
                vals.append(-get_avg_val(matching_extractions, key))
            errors.append(get_std_val(matching_extractions, key))
            labels.append(direction)
    
    if label == "Torque auc [Nms]": 
        for direction in directions[1]:
            key = directions[1][direction][0] + main_key + directions[1][direction][-1]
            if get_avg_val(matching_extractions, key) >= 0:
                vals.append(get_avg_val(matching_extractions, key))
            else:
                vals.append(-get_avg_val(matching_extractions, key))
            errors.append(get_std_val(matching_extractions, key))
            labels.append(direction)
    
    return vals, labels, errors


    
def plot_bar_from_data(data, key, ax, label, per_teeth, grouped, teeth, upper_lower):
    main_key = key
    
    if per_teeth:
        vals, labels, errors = plot_bar_per_teeth(data, main_key)
   
    if not per_teeth:
        if grouped:
            matching_extractions = []
            for tooth in teeth:
                matching_extractions.append(filter_extraction(data, upper_lower, tooth))
        else:
            tooth = teeth
            matching_extractions = filter_extraction(data, upper_lower, tooth)
        
        vals, labels, errors = plot_bar_per_direction(data, matching_extractions, main_key, label, tooth, upper_lower)
        
    ax.barh(labels, vals, xerr=errors)
    ax.set_xlabel(label)


def plot_analysis(analysis, per_teeth, grouped, teeth, upper):
    if per_teeth:
        fig, ax = plt.subplots(2, 3)
        plot_bar_from_data(analysis, "auc", ax[0][0], "Force auc [Ns]", per_teeth, grouped,  teeth, upper)
        plot_bar_from_data(analysis, "auc", ax[0][1], "Torque auc [Nms]", per_teeth, grouped, teeth, upper)
        plot_bar_from_data(analysis, "max", ax[1][0], "Force max [N]", per_teeth, teeth, grouped, upper)
        plot_bar_from_data(analysis, "max", ax[1][1], "Torque max [Nms]", per_teeth, teeth, grouped, upper)
        plot_bar_from_data(analysis, "direction_changes", ax[0][2], "Direction changes", per_teeth, grouped, teeth, upper)
        fig.suptitle('Data per teeth', fontsize=30)
        
    else:
        if grouped:
            fig, ax = plt.subplots(4, 2)
                   
            plot_bar_from_data(analysis, "auc", ax[0][0], "Force auc [Ns]", per_teeth, grouped, groups['incisors'], upper)
            plot_bar_from_data(analysis, "auc", ax[0][1], "Torque auc [Nms]", per_teeth, grouped, groups['incisors'], upper)            
            ax[0, 0].set_title('incisors')
            ax[0, 1].set_title('incisors')
            
            plot_bar_from_data(analysis, "auc", ax[1][0], "Force auc [Ns]", per_teeth, grouped, groups['molars'], upper)
            plot_bar_from_data(analysis, "auc", ax[1][1], "Torque auc [Nms]", per_teeth, grouped, groups['molars'], upper)
            ax[1, 0].set_title('molars')
            ax[1, 1].set_title('molars')
            
            plot_bar_from_data(analysis, "auc", ax[2][0], "Force auc [Ns]", per_teeth, grouped, groups['canines'], upper)
            plot_bar_from_data(analysis, "auc", ax[2][1], "Torque auc [Nms]", per_teeth, grouped, groups['canines'], upper)
            ax[2, 0].set_title('canines')
            ax[2, 1].set_title('canines')
            
            plot_bar_from_data(analysis, "auc", ax[3][0], "Force auc [Ns]", per_teeth, grouped, groups['premolars'], upper)
            plot_bar_from_data(analysis, "auc", ax[3][1], "Torque auc [Nms]", per_teeth, grouped, groups['premolars'], upper)
            ax[3, 0].set_title('premolars')
            ax[3, 1].set_title('premolars')
            
            if upper:
                fig.suptitle('Data per clinical direction for upper jaw teeth' , fontsize=12)
            else:
                fig.suptitle('Data per clinical direction for lower jaw teeth', fontsize=12)
            
        else:
            matching_extractions = filter_extraction(analysis, upper, teeth)
            fig, ax = plt.subplots(1, 2)
            plot_bar_from_data(analysis, "auc", ax[0], "Force auc [Ns]", per_teeth, grouped, teeth, upper)
            plot_bar_from_data(analysis, "auc", ax[1], "Torque auc [Nms]", per_teeth, grouped, teeth, upper)
            if upper:
                fig.suptitle('Data per clinical direction for upper jaw tooth: ' + str(teeth) + ', ' + " (n = {})".format(len(matching_extractions)), fontsize=20)
            else:
                fig.suptitle('Data per clinical direction for lower jaw tooth: ' + str(teeth) + ', ' + " (n = {})".format(len(matching_extractions)), fontsize=20)
    show_plots(fig)

def generate_ft_plots(files, dataDir):
    os.makedirs(os.path.join(dataDir, "ft-plots"), exist_ok = True)
    for f in files:
        graph_ft(f, dataDir, False)
