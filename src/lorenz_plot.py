import matplotlib.pyplot as plt
import numpy as np

# -------------------------
# USER PARAMETERS
# -------------------------
start_idx = 0      # <-- start index (inclusive)
end_idx   = 10000    # <-- end index (exclusive), e.g. 10, 900, etc.

# -------------------------
# 1) Load C++ fixed-point results
# -------------------------
x_cpp = np.loadtxt("x.txt")
y_cpp = np.loadtxt("y.txt")
z_cpp = np.loadtxt("z.txt")

# -------------------------
# 2) Python (float) computation — your code
# -------------------------
dt = (1.0/256.0)
x = [-1.0]
y = [0.1]
z = [25.0]
sigma = 10.0
beta = 8.0/3.0
rho = 28.0

def dx(sigma, x, y):
    return sigma*(y-x)

def dy(rho, x, y, z):
    return x*(rho-z)-y

def dz(beta, x, y, z):
    return x*y - beta*z

for i in range(10000):
    x.extend([x[i] + dt*dx(sigma, x[i], y[i])])
    y.extend([y[i] + dt*dy(rho, x[i], y[i], z[i])])
    z.extend([z[i] + dt*dz(beta, x[i], y[i], z[i])])


# -------------------------
# Save Python-computed signals to files
# -------------------------
with open("x_py.txt", "w") as fx, \
     open("y_py.txt", "w") as fy, \
     open("z_py.txt", "w") as fz:
    for xi, yi, zi in zip(x[:], y[:], z[:]):  # skip the initial value to align with C++
        fx.write(f"{xi:.6f}\n")
        fy.write(f"{yi:.6f}\n")
        fz.write(f"{zi:.6f}\n")

print("Python-computed signals written to x_py.txt, y_py.txt, z_py.txt")




# Convert to numpy arrays
x_py_full = np.array(x)
y_py_full = np.array(y)
z_py_full = np.array(z)

# -------------------------
# 3) Align Python vs C++ lengths
# -------------------------
x_py = x_py_full[1:]
y_py = y_py_full[1:]
z_py = z_py_full[1:]

N = min(len(x_cpp), len(x_py))
x_cpp, y_cpp, z_cpp = x_cpp[:N], y_cpp[:N], z_cpp[:N]
x_py, y_py, z_py = x_py[:N], y_py[:N], z_py[:N]

# -------------------------
# 4) Extract plotting window
# -------------------------
start_idx = max(0, start_idx)
end_idx = min(N, end_idx)
x_cpp = x_cpp[start_idx:end_idx]
y_cpp = y_cpp[start_idx:end_idx]
z_cpp = z_cpp[start_idx:end_idx]
x_py = x_py[start_idx:end_idx]
y_py = y_py[start_idx:end_idx]
z_py = z_py[start_idx:end_idx]
steps = np.arange(start_idx, end_idx)

# -------------------------
# 5) Compute differences
# -------------------------
dx_err = x_py - x_cpp
dy_err = y_py - y_cpp
dz_err = z_py - z_cpp

# -------------------------
# 6) Plot sections
# -------------------------
# (A) Python-only
fig1, axes1 = plt.subplots(3, 1, sharex=True, figsize=(9, 7))
axes1[0].plot(steps, x_py); axes1[0].set_ylabel("x (Python)")
axes1[1].plot(steps, y_py); axes1[1].set_ylabel("y (Python)")
axes1[2].plot(steps, z_py); axes1[2].set_ylabel("z (Python)")
axes1[2].set_xlabel("Time Steps")
fig1.suptitle(f"Lorenz Variables (Python) [{start_idx}:{end_idx}]")

# (B) Overlay
fig2, axes2 = plt.subplots(3, 1, sharex=True, figsize=(9, 7))
axes2[0].plot(steps, x_py, label="Python (float)")
axes2[0].plot(steps, x_cpp, '--', label="C++ (fixed)")
axes2[0].set_ylabel("x"); axes2[0].legend()

axes2[1].plot(steps, y_py, label="Python (float)")
axes2[1].plot(steps, y_cpp, '--', label="C++ (fixed)")
axes2[1].set_ylabel("y"); axes2[1].legend()

axes2[2].plot(steps, z_py, label="Python (float)")
axes2[2].plot(steps, z_cpp, '--', label="C++ (fixed)")
axes2[2].set_ylabel("z"); axes2[2].set_xlabel("Time Steps"); axes2[2].legend()
fig2.suptitle(f"Overlay: Python vs C++ [{start_idx}:{end_idx}]")

# (C) Differences
fig3, axes3 = plt.subplots(3, 1, sharex=True, figsize=(9, 7))
axes3[0].plot(steps, dx_err); axes3[0].axhline(0, color='k', lw=0.8); axes3[0].set_ylabel("x diff")
axes3[1].plot(steps, dy_err); axes3[1].axhline(0, color='k', lw=0.8); axes3[1].set_ylabel("y diff")
axes3[2].plot(steps, dz_err); axes3[2].axhline(0, color='k', lw=0.8); axes3[2].set_ylabel("z diff")
axes3[2].set_xlabel("Time Steps")
fig3.suptitle(f"Differences (Python − C++) [{start_idx}:{end_idx}]")

plt.show()
