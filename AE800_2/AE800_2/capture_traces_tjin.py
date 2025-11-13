import os, time, json, warnings
warnings.filterwarnings("ignore", message=r"pkg_resources is deprecated as an API\.", category=UserWarning)

import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm
import chipwhisperer as cw

# =========================
#      USER SETTINGS
# =========================
BSFILE = r"C:\Users\ielkhazin\Downloads\AE800_2\AE800_2\AE800_2.runs\impl_1\cw305_aes_top.bit"
OUTDIR = "out_aes_fast"
os.makedirs(OUTDIR, exist_ok=True)

N_TRACES     = 500
ADC_SAMPLES  = 1000
ADC_DECIMATE = 1
GAIN_DB      = 45
ADC_FREQ_HZ  = 100e6       # sample rate
TIMEOUT_S    = 2.0
MIN_GAP_S    = 0.001

TRIGGER_LINE = "tio4"      # RTL 'trigger' -> CW 20-pin TIO4
TRIGGER_EDGE = "rising"

# For metadata only (what your RTL uses when it runs)
FIXED_PLAINTEXT = bytearray.fromhex("3243f6a8885a308d313198a2e0370734")
FIXED_KEY       = bytearray.fromhex("2b7e151628aed2a6abf7158809cf4f3c")

# =========================
#     HELPER FUNCTIONS
# =========================
def setup_scope(scope):
    scope.adc.samples  = ADC_SAMPLES
    scope.adc.offset   = 0
    scope.adc.decimate = ADC_DECIMATE
    scope.adc.timeout  = TIMEOUT_S
    scope.gain.db      = GAIN_DB

    # Use internal clkgen at 100 MHz for sampling
    scope.clock.clkgen_freq = ADC_FREQ_HZ
    scope.clock.adc_src     = "clkgen_x1"
    if hasattr(scope.clock, "reset_adc"):
        scope.clock.reset_adc()
    time.sleep(0.1)

    # Set trigger source to TIO4, edge to rising
    if hasattr(scope.trigger, "triggers"):
        scope.trigger.triggers = TRIGGER_LINE
    elif hasattr(scope.trigger, "source"):
        scope.trigger.source = TRIGGER_LINE

    try:
        scope.adc.basic_mode = "rising_edge" if TRIGGER_EDGE == "rising" else "falling_edge"
    except Exception:
        pass

    # Make sure we don't accidentally drive anything
    for tio_attr in ("tio1", "tio2", "tio3", "tio4"):
        try:
            getattr(scope.io, tio_attr)  # ensure attribute exists
            # leave them in default/high_z; don't force serial modes
        except Exception:
            pass

    return float(getattr(scope.clock, "adc_freq", 0.0) or 0.0)

def program_fpga_with_fallback(scope, target, bitfile):
    """Try several programming APIs for CW305; return (target, method_used)."""
    attempts = []

    # 1) Try load_bitstream
    try:
        if hasattr(target, "fpga") and hasattr(target.fpga, "load_bitstream"):
            target.fpga.load_bitstream(bitfile)
            return target, "fpga.load_bitstream"
    except Exception as e:
        attempts.append(f"load_bitstream: {e}")

    # 2) Try load_bitfile
    try:
        if hasattr(target, "fpga") and hasattr(target.fpga, "load_bitfile"):
            target.fpga.load_bitfile(bitfile)
            return target, "fpga.load_bitfile"
    except Exception as e:
        attempts.append(f"load_bitfile: {e}")

    # 3) Re-open target with bsfile=... so it programs on connect
    try:
        # Some installs accept fpga_id; if yours does, add fpga_id='100t'
        target.dis()
        target = cw.target(scope, cw.targets.CW305, bsfile=bitfile, force=True)
        return target, "ctor(bsfile=...)"
    except Exception as e:
        attempts.append(f"ctor(bsfile): {e}")

    raise RuntimeError("FPGA programming failed. Tried -> " + " | ".join(attempts))

def setup_cw305_clock(target):
    """Try to drive FPGA from CW305 PLL at 100 MHz. Silent if not supported."""
    try:
        # API variant 1 (newer):
        target.pll.dp_mclk = ADC_FREQ_HZ
        time.sleep(0.1)
        target.fpga.clk_src = "pll_mclk"
        return "pll_mclk"
    except Exception:
        pass
    try:
        # API variant 2 (older):
        target.pll.pll_outfreq_set(ADC_FREQ_HZ)   # set PLL1 to 100 MHz
        # some versions need enable calls; ignore if not present
        try: target.pll.pll_enable_set(True)
        except Exception: pass
        try: target.pll.pll_outenable_set(True)
        except Exception: pass
        return "pll_outfreq_set"
    except Exception:
        return "unmodified"

def save_plots(traces, outdir):
    if traces.size == 0:
        return
    # First trace
    plt.figure(figsize=(9, 3))
    plt.plot(traces[0])
    plt.title("First Power Trace")
    plt.xlabel("Sample"); plt.ylabel("ADC")
    plt.tight_layout(); plt.savefig(os.path.join(outdir, "trace_first.png"), dpi=150); plt.close()

    # Overlay up to 50
    n_overlay = min(50, traces.shape[0])
    plt.figure(figsize=(9, 3))
    for i in range(n_overlay):
        plt.plot(traces[i], alpha=0.25)
    plt.title(f"Overlay of {n_overlay} Traces")
    plt.xlabel("Sample"); plt.ylabel("ADC")
    plt.tight_layout(); plt.savefig(os.path.join(outdir, "traces_overlay.png"), dpi=150); plt.close()

    # Mean ± Std
    mean = traces.mean(axis=0); std = traces.std(axis=0); x = np.arange(traces.shape[1])
    plt.figure(figsize=(9, 3))
    plt.plot(x, mean, label="Mean")
    plt.fill_between(x, mean-std, mean+std, alpha=0.3, label="±1 std")
    plt.title("Mean ± Std of Traces"); plt.xlabel("Sample"); plt.ylabel("ADC"); plt.legend()
    plt.tight_layout(); plt.savefig(os.path.join(outdir, "mean_std.png"), dpi=150); plt.close()

# =========================
#           MAIN
# =========================
def main():
    scope = None
    target = None
    try:
        print("[scope] Connecting …")
        scope = cw.scope()
        adc_f = setup_scope(scope)
        print(f"[scope] adc_freq = {adc_f:.2f} Hz | samples={ADC_SAMPLES} | gain={GAIN_DB} dB")

        print("[cw305] Connecting …")
        target = cw.target(scope, cw.targets.CW305)

        if not os.path.isfile(BSFILE):
            raise FileNotFoundError(f"Bitfile not found:\n{BSFILE}")

        print(f"[fpga] Programming bitfile:\n       {BSFILE}")
        target, method = program_fpga_with_fallback(scope, target, BSFILE)
        print(f"[fpga] Programmed via: {method}")

        clk_method = setup_cw305_clock(target)
        print(f"[cw305] Clock setup method: {clk_method}")

        # Capture
        traces_raw = np.zeros((N_TRACES, ADC_SAMPLES), dtype=np.float32)
        ok = 0; timeouts = 0

        print("[capture] Waiting for FPGA to assert trigger on TIO4 …")
        pbar = tqdm(range(N_TRACES), ncols=100, desc="Capture")
        for i in pbar:
            scope.arm()
            # Auto-trigger only; no button pulses
            timed_out = bool(scope.capture(poll_done=True))
            if timed_out or getattr(scope, "is_timed_out", lambda: False)():
                timeouts += 1
                pbar.set_postfix_str(f"ok={ok}/{i+1} TIMEOUT")
                continue

            tr = scope.get_last_trace()
            if tr is None or tr.size != ADC_SAMPLES:
                timeouts += 1
                pbar.set_postfix_str(f"ok={ok}/{i+1} BAD_TRACE")
                continue

            traces_raw[ok, :] = tr.astype(np.float32, copy=False)
            ok += 1
            pbar.set_postfix_str(f"ok={ok}/{i+1}")
            time.sleep(MIN_GAP_S)

        print(f"[done] captured {ok}/{N_TRACES} traces (timeouts={timeouts})")
        traces_ok = traces_raw[:ok]

        # Save arrays
        np.save(os.path.join(OUTDIR, "cw_traces_raw.npy"), traces_ok)
        if ok > 0:
            pt_array  = np.tile(np.frombuffer(FIXED_PLAINTEXT, dtype=np.uint8), (ok, 1))
            key_array = np.tile(np.frombuffer(FIXED_KEY,       dtype=np.uint8), (ok, 1))
            np.save(os.path.join(OUTDIR, "plaintexts.npy"), pt_array)
            np.save(os.path.join(OUTDIR, "keys.npy"),       key_array)
            print(f"[save] {OUTDIR}/plaintexts.npy, {OUTDIR}/keys.npy")

            # QC plots
            save_plots(traces_ok, OUTDIR)

        # Metadata
        meta = dict(
            n_traces=int(N_TRACES), ok=int(ok), timeouts=int(timeouts),
            adc_samples=int(ADC_SAMPLES), adc_freq=float(adc_f),
            gain_db=float(GAIN_DB), decimate=int(ADC_DECIMATE),
            trigger_line=TRIGGER_LINE, trigger_edge=TRIGGER_EDGE,
            bitfile=BSFILE,
            clock_setup=clk_method,
            fixed_plaintext=FIXED_PLAINTEXT.hex(),
            fixed_key=FIXED_KEY.hex(),
        )
        with open(os.path.join(OUTDIR, "capture_meta.json"), "w") as f:
            json.dump(meta, f, indent=2)

        print(f"[save] {OUTDIR}/cw_traces_raw.npy, {OUTDIR}/capture_meta.json")
        if ok > 0:
            print(f"[plots] saved: trace_first.png, traces_overlay.png, mean_std.png in {OUTDIR}")

    except Exception as e:
        print(f"[ERROR] {e}")
    finally:
        # Clean up in all cases
        try:
            if scope: scope.dis()
        except Exception:
            pass
        try:
            if target: target.dis()
        except Exception:
            pass
        print("[cleanup] Disconnected.")

if __name__ == "__main__":
    main()
