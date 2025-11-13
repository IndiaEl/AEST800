# plot_traces_safe.py
import os, json
import numpy as np
import matplotlib.pyplot as plt

INDIR = r"C:\Users\ielkhazin\Downloads\AE800_2\AE800_2\out_aes_fast"
TRACE_FILE = "cw_traces_raw.npy"
NUM_TO_OVERLAY = 20
SHOW_PLOTS = False

trace_path = TRACE_FILE if os.path.isabs(TRACE_FILE) else os.path.join(INDIR, TRACE_FILE)
meta_path  = os.path.join(INDIR, "capture_meta.json")

print(f"Loading traces from {trace_path} ...")
if not os.path.isfile(trace_path):
    raise FileNotFoundError(trace_path)

traces = np.load(trace_path, mmap_mode="r")
print(f"Trace array shape: {traces.shape}")

# If meta file exists, print summary
if os.path.isfile(meta_path):
    try:
        with open(meta_path, "r") as f:
            meta = json.load(f)
        print("Capture meta:", {k: meta[k] for k in ("ok","n_traces","timeouts","trigger_line","adc_samples","gain_db") if k in meta})
    except Exception:
        pass

# Handle empty gracefully
if traces.ndim != 2 or traces.shape[0] == 0:
    print("\nNo traces to plot (n_traces = 0). This means capture timed out or trigger never fired.")
    print("Fix capture, then re-run this script.")
    raise SystemExit(0)

n_traces, n_samples = traces.shape

# First trace
first_png = os.path.join(INDIR, "trace_first.png")
plt.figure(figsize=(10,4))
plt.plot(traces[0])
plt.title("First Power Trace")
plt.xlabel("Sample #")
plt.ylabel("ADC (raw)")
plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig(first_png, dpi=150)
if SHOW_PLOTS: plt.show()
plt.close()
print(f"Saved: {first_png}")

# Overlay
overlay_png = os.path.join(INDIR, "traces_overlay.png")
m = min(NUM_TO_OVERLAY, n_traces)
plt.figure(figsize=(10,4))
for i in range(m):
    plt.plot(traces[i], alpha=0.35, linewidth=0.8)
plt.title(f"Overlay of {m} Traces")
plt.xlabel("Sample #"); plt.ylabel("ADC (raw)")
plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig(overlay_png, dpi=150)
if SHOW_PLOTS: plt.show()
plt.close()
print(f"Saved: {overlay_png}")

# Mean ± Std
mean_png = os.path.join(INDIR, "traces_mean_std.png")
mean = np.mean(traces, axis=0); std = np.std(traces, axis=0)
x = np.arange(n_samples)
plt.figure(figsize=(10,4))
plt.plot(x, mean, label="Mean")
plt.fill_between(x, mean-std, mean+std, alpha=0.3, label="±1σ")
plt.title(f"Mean ± Std over {n_traces} Traces")
plt.xlabel("Sample #"); plt.ylabel("ADC (raw)")
plt.grid(True, alpha=0.3); plt.legend()
plt.tight_layout(); plt.savefig(mean_png, dpi=150)
if SHOW_PLOTS: plt.show()
plt.close()
print(f"Saved: {mean_png}")

print("\nAll done.")
