import numpy as np
from scipy.interpolate import CubicSpline

def get_forces(dic):
    return [dic["buccal/lingual"], dic["mesial/distal"], dic["extrusion/intrusion"]]

def get_torques(dic):
    return [dic["mesial/distal angulation"], dic["bucco/linguoversion"], dic["mesiobuccal/lingual"]]

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
    arr = np.array(vectors)
    return np.linalg.norm(arr, axis=0)

def merge_vectors(x, y, z):
    return np.column_stack([x,y,z])

def get_smoothened_line(vectors, n_points):
    x = range(len(vectors))
    x_smooth = np.linspace(0, len(vectors)-1, n_points)
    cs = CubicSpline(x, vectors)
    return x_smooth, cs

def cut_off_start_end_vec(start, end, vec):
    return vec[start:end]

def get_axis_names():
    return ["buccal/lingual", "mesial/distal", "extrusion/intrusion", "mesial/distal angulation", "bucco/linguoversion", "mesiobuccal/lingual"]


def cut_off_start_end_dic(start, end, dic):
    axes = get_axis_names()
    for a in axes:
        dic[a] = cut_off_start_end_vec(start,end,dic[a])

    return dic

