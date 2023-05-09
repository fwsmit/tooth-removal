import numpy as np
from scipy.signal import find_peaks, butter, lfilter
from scipy.fft import fft, fftfreq
from scipy.ndimage import uniform_filter1d

from vec_util import *

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
