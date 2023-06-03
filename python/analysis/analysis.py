import numpy as np
from scipy.signal import find_peaks, butter, lfilter
from scipy.fft import fft, fftfreq
from scipy.ndimage import uniform_filter1d

from vec_util import *
from json_parse import *
from data_util import *

# Sample frequency of sensor
frequency = 1000

def get_sample_frequency():
    return frequency

def get_positive_values(v):
    return v[v > 0]

def get_negative_values(v):
    return v[v < 0]

## The following parameters are from the "Forces and Torques in Tooth Removal 2019" paper.
## They can be used to compare the data to their dataset

def get_sec(v):
    return len(v)/frequency

# sec_pos = time in seconds, only positive values are included
def get_sec_pos(v):
    return len(get_positive_values(v))/frequency

# sec_neg = time in seconds, only negative values are included
def get_sec_neg(v):
    return len(get_negative_values(v))/frequency

# auc = area under the curve (Ns or ‘impuls’ and Nms for torques)
def get_auc(v):
    return np.trapz(v, dx=1/frequency)

# auc_sec = area under the curve divided by time in seconds
def get_auc_sec(v):
    sec = get_sec(v)
    return get_auc(v)/sec

# auc_pos = area under the curve, only positive values are included
def get_auc_pos(v):
    v_pos = get_positive_values(v)
    return get_auc(v_pos)

# auc_pos_sec = area under the curve, only positive values are included, divided by time in seconds
def get_auc_pos_sec(v):
    sec = get_sec_pos(v)
    if sec == 0:
        return 0
    return get_auc_pos(v)/sec

# auc_neg = area under the curve, only negative values are included
def get_auc_neg(v):
    v_neg = get_negative_values(v)
    return get_auc(v_neg)

# auc_neg_sec = area under the curve, only negative values are included, divided by time in seconds
def get_auc_neg_sec(v):
    sec = get_sec_neg(v)
    if sec == 0:
        return 0
    return get_auc_neg(v)/sec

# max = maximum value (N for force and Nm for torques)
def get_max(v):
    return max(v)

def get_axis_parameters(v, axisName, is_mag=False):
    params = ["auc", "auc_sec", "auc_pos", "auc_pos_sec", "auc_neg", "auc_neg_sec", "max", "sec_pos", "sec_neg"]
    dic = {}
    for p in params:
        funcname = "get_"+p
        if is_mag and "neg" in funcname or is_mag and "pos" in funcname:
            continue
        func = globals()[funcname]
        val = func(v)
        dic[axisName+"_"+p] = val
        
    return dic

def get_parameters(forces, torques):
    f_names = ["fx", "fy", "fz"]
    t_names = ["tx", "ty", "tz"]
    dic = {}

    for i in range(len(forces)):
        dic.update(get_axis_parameters(forces[i], f_names[i]))
        dic.update(get_axis_parameters(torques[i], t_names[i]))
    
    f_mag = norm_vectors(forces)
    t_mag = norm_vectors(torques)
    dic.update(get_axis_parameters(f_mag, "fmag", True))
    dic.update(get_axis_parameters(t_mag, "tmag", True))
    return dic

## End of comparison parameters

def get_file_processed(filename, dataDir):
    dic = parse_json(filename, dataDir)

    forces = get_forces(dic)
    torques = get_torques(dic)
    if len(forces) == 0 or len(forces[0]) == 0:
        return None
    lowpass_filter_all_dic(dic)
    start, end = find_starting_point(forces, torques)
    cut_off_start_end_dic(start, end, dic)

    return dic

def butter_lowpass(cutoff, fs, order=5):
    return butter(order, cutoff, fs=fs, btype='lowpass', analog=False)

def lowpass_filter(vec, cutoff, fs=1000, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, vec)
    return y

def lowpass_filter_all_dic(dic):
    cutoff = 3
    axes = get_axis_names()
    for a in axes:
        dic[a] = lowpass_filter(dic[a], cutoff)

def lowpass_filter_all(forces, torques):
    cutoff = 3
    for i in range(len(forces)):
        forces[i] = lowpass_filter(forces[i], cutoff)
        torques[i] = lowpass_filter(torques[i], cutoff)

    return forces, torques


def get_direction_changes(v, peaks):
    count = 0
    sign = 0

    for p in peaks:
        y = v[round(p)]
        if sign != np.sign(y):
            count += 1
            sign = np.sign(y)

    return count

def find_start_end_from_vec(vec, threshold):
    abs_vec = norm_vectors(vec)

    greater = np.argwhere(abs_vec > threshold)

    if len(greater) == 0:
        return 0, len(abs_vec)-1

    return greater[0][0], greater[-1][0]

def find_starting_point(force, torque):
    force_start, force_end = find_start_end_from_vec(force, 4)
    torque_start, torque_end = find_start_end_from_vec(torque, 0.3)
    margin = 700
    start = min(force_start, torque_start) - margin
    end = max(force_end, torque_end) + margin
    start = max(start, 0)
    end = min(end, len(force[0])-1)
    return start, end

def analyze_peaks(vectors):
    peak_width_min = 100
    prominence_min = 0.25
    peaks, properties = find_peaks(vectors, width=peak_width_min, prominence=prominence_min)
    return peaks

def analyze_file(filename, dataDir):
    dic = get_file_processed(filename, dataDir)
    forces = get_forces(dic)
    torques = get_torques(dic)
    dic.update(get_parameters(forces, torques))

    main_axis = torques[1]
    torque_mag = norm_vectors(torques)
    peaks = analyze_peaks(np.abs(main_axis))
    dic["direction_changes"] = get_direction_changes(main_axis, peaks)
    return dic

def complete_analysis(files, dataDir, person_type):
    analysis = []
    for f in files:
        dic = analyze_file(f, dataDir)
        if dic:
            analysis.append(dic)
    analysis = filter_complications(analysis)
    
    if person_type:
        person_type = person_type.split(",")
        analysis = filter_people(analysis, person_type)
    return analysis

