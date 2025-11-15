# Quick Start Guide - AEST800 Trojan Simulation

This guide will help you quickly set up and run the AEST800 trojan simulation framework.

## Step 1: Prerequisites Check

### Check if Icarus Verilog is installed
```bash
iverilog -v
```

If not installed:
- **Ubuntu/Debian**: `sudo apt-get install iverilog`
- **macOS**: `brew install icarus-verilog`

### Check if Python is installed
```bash
python3 --version
```

### Install Python dependencies
```bash
pip3 install matplotlib pandas numpy
```

## Step 2: Run the Simulation

```bash
cd /path/to/AEST800
./scripts/run_simulation.sh
```

**What happens:**
- Compiles both AES implementations (clean and trojan)
- Runs testbench with 4 test vectors
- Generates 6 CSV trace files in `results/` directory
- Takes approximately 10-30 seconds

**Expected output:**
```
===================================
AEST800 Trojan Simulation Framework
===================================

Step 1: Compiling Verilog sources...
Step 2: Running simulation...
=== AES-128 Simulation Started ===
Generating power, timing, and EM traces...
Test 1 completed:
  Clean    - Cycles: XX, Ciphertext: ...
  Trojan   - Cycles: XX, Ciphertext: ...
...
=== Simulation Complete ===
```

## Step 3: Visualize the Traces

```bash
python3 scripts/plot_traces.py
```

**Generates 4 plots:**
1. `results/power_traces.png` - Compare power consumption
2. `results/timing_comparison.png` - Compare execution cycles
3. `results/em_traces.png` - Compare EM emissions
4. `results/difference_analysis.png` - Show differences

## Step 4: Analyze the Results

```bash
python3 scripts/analyze_traces.py
```

**Output includes:**
- Statistical analysis of power consumption
- Timing overhead calculations
- EM signature analysis
- Trojan detection summary

**Sample output:**
```
============================================================
POWER TRACE ANALYSIS
============================================================

Clean Implementation:
  Mean Power:      XXX.XX
  Std Deviation:   XX.XX
  
Trojan-Infected Implementation:
  Mean Power:      XXX.XX
  Std Deviation:   XX.XX
  
Power Overhead:
  Mean increase:   XX.XX%
  
============================================================
TROJAN DETECTION SUMMARY
============================================================

Detection Indicators:
  ⚠ Power Analysis:    ANOMALY DETECTED (XX.XX% increase)
  ⚠ Timing Analysis:   ANOMALY DETECTED (XX.XX% overhead)
  ⚠ EM Analysis:       ANOMALY DETECTED (XX.XX% increase)

Conclusion:
  ⚠⚠⚠ HARDWARE TROJAN LIKELY PRESENT ⚠⚠⚠
  3/3 detection methods show anomalies
```

## Understanding the Test Cases

The simulation runs 4 test cases:

### Test 1 & 4: Normal Operation
- Trojan is **NOT** triggered
- Clean and trojan implementations should show similar behavior
- Minor differences due to simulation noise

### Test 2 & 3: Trojan Activation
- Trojan **IS** triggered (special plaintext patterns)
- Significant differences in:
  - Power consumption (extra switching)
  - Timing (additional delay cycles)
  - EM emissions (trojan activity)

## Key Files to Examine

### Verilog Sources
- `rtl/aes128_clean.v` - Baseline AES implementation
- `rtl/aes128_trojan.v` - AES with trojan (see lines with "TROJAN" comments)
- `tb/aes128_tb.v` - Testbench with trace generation logic

### Generated Traces
- `results/power_trace_*.csv` - Cycle-by-cycle power data
- `results/timing_trace_*.csv` - Total cycles per test
- `results/em_trace_*.csv` - Cycle-by-cycle EM activity

### Analysis Scripts
- `scripts/plot_traces.py` - Visualization (matplotlib)
- `scripts/analyze_traces.py` - Statistical analysis (pandas/numpy)

## Troubleshooting

### "Command not found: iverilog"
→ Install Icarus Verilog (see Prerequisites)

### "No module named matplotlib"
→ Run: `pip3 install matplotlib pandas numpy`

### "Error: Compilation failed"
→ Check Verilog syntax, ensure all files are present

### "No such file or directory: results/"
→ Directory should be created automatically; create manually: `mkdir results`

### No visible differences in plots
→ Check test 2 and 3 results specifically (trojan triggered)
→ The trojan activates only on specific plaintext patterns

## Next Steps

### Experiment with Different Triggers
Edit `rtl/aes128_trojan.v` line ~28:
```verilog
assign trojan_trigger = (plaintext[15:0] == 16'hABCD) || ...
```
Change trigger patterns and re-run simulation.

### Add More Test Cases
Edit `tb/aes128_tb.v` and add new test vectors in the initial block.

### Customize Analysis
Create your own Python scripts in `scripts/` to perform custom analysis on the CSV files.

### Make Trojan More Stealthy
Reduce the power leakage and timing overhead in `rtl/aes128_trojan.v` to make it harder to detect.

## Common Questions

**Q: Why do both implementations produce different ciphertexts?**  
A: The trojan implementation uses a simplified AES algorithm for demonstration. Both are simplified and not NIST-compliant.

**Q: How realistic is this trojan?**  
A: This is an educational demonstration. Real trojans are much more sophisticated and harder to detect.

**Q: Can I use this for research?**  
A: This is a starting point. For serious research, use full AES implementations and more sophisticated analysis techniques.

**Q: How do I add more trojan types?**  
A: Create new modules based on `aes128_trojan.v` with different trigger mechanisms and payloads.

## Resources

- [Icarus Verilog Documentation](http://iverilog.icarus.com/)
- [Hardware Trojan Taxonomy (IEEE)](https://ieeexplore.ieee.org/)
- [Side-Channel Analysis Papers](https://www.iacr.org/)

## Getting Help

If you encounter issues:
1. Check this guide's Troubleshooting section
2. Review the main README.md
3. Open an issue on GitHub with:
   - Error messages
   - Your environment (OS, tool versions)
   - Steps to reproduce
