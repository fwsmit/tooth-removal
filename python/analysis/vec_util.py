import numpy as np
from scipy.interpolate import CubicSpline

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

# Return length of all vectors in array
def vectors_mag(vectors):
    mags = []
    for v in vectors:
        mags.append(np.linalg.norm(v))

    return mags

def get_smoothened_line(vectors, n_points):
    x = range(len(vectors))
    x_smooth = np.linspace(0, len(vectors)-1, n_points)
    cs = CubicSpline(x, vectors)
    return x_smooth, cs

