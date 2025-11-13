# Complete Usage Example

This document provides a step-by-step walkthrough of using the AEST800 trojan simulation framework.

## Prerequisites

Ensure you have:
- Icarus Verilog installed
- Python 3 with matplotlib, pandas, and numpy

## Step-by-Step Tutorial

### 1. Clone and Setup

```bash
git clone https://github.com/IndiaEl/AEST800.git
cd AEST800
```

### 2. Run the Simulation

Execute the simulation script:

```bash
./scripts/run_simulation.sh
```

**Expected Output:**
```
===================================
AEST800 Trojan Simulation Framework
===================================

Step 1: Compiling Verilog sources...
Step 2: Running simulation...
=== AES-128 Simulation Started ===
Generating power, timing, and EM traces...
Test 1 completed:
  Clean    - Cycles: 1, Ciphertext: 8c9daebfc0d1e2f30415263748596a7b
  Trojan   - Cycles: 1, Ciphertext: 8c9daebfc0d1e2f30415263748596a7b
Test 2 completed (TROJAN TRIGGERED):
  Clean    - Cycles: 1, Ciphertext: 8c9daebfc0d1e2f30415263748592f49
  Trojan   - Cycles: 1, Ciphertext: 8c9daebfc0d1e2f30415263748592f49
Test 3 completed (TROJAN TRIGGERED):
  Clean    - Cycles: 1, Ciphertext: 0a06312c4e427568828eb9a41823131f
  Trojan   - Cycles: 1, Ciphertext: 0a06312c4e427568828eb9a41823131f

=== Simulation Complete ===
```

**Time:** ~10 seconds

### 3. Analyze the Traces

Run the statistical analysis:

```bash
python3 scripts/analyze_traces.py
```

**Expected Output:**
```
============================================================
AEST800 TROJAN TRACE ANALYSIS
============================================================

============================================================
POWER TRACE ANALYSIS
============================================================

Clean Implementation:
  Mean Power:      360.00
  Std Deviation:   187.62
  Min Power:       0.00
  Max Power:       560.00

Trojan-Infected Implementation:
  Mean Power:      400.00
  Std Deviation:   252.98
  Min Power:       0.00
  Max Power:       800.00

Power Overhead:
  Mean increase:   11.11%
  Absolute diff:   40.00
  Correlation:     0.9439

============================================================
TIMING ANALYSIS
============================================================

Test-by-Test Comparison:
Test   Clean      Trojan     Diff       % Overhead
------------------------------------------------------------
1      1          1          0            0.00%
2      1          1          0            0.00%
------------------------------------------------------------
Average Timing Overhead: 0.00%

============================================================
ELECTROMAGNETIC EMISSION ANALYSIS
============================================================

Clean Implementation:
  Mean EM Activity:    93.17
  Std Deviation:       45.68

Trojan-Infected Implementation:
  Mean EM Activity:    112.17
  Std Deviation:       72.44

EM Signature Changes:
  Mean increase:       20.39%
  Absolute diff:       19.00

============================================================
TROJAN DETECTION SUMMARY
============================================================

Detection Indicators:
  ⚠ Power Analysis:    ANOMALY DETECTED (11.11% increase)
  ✓ Timing Analysis:   Normal
  ⚠ EM Analysis:       ANOMALY DETECTED (20.39% increase)

Conclusion:
  ⚠⚠⚠ HARDWARE TROJAN LIKELY PRESENT ⚠⚠⚠
  2/3 detection methods show anomalies
```

**Key Insight:** The analysis successfully detected the hardware trojan through power and EM signatures!

### 4. Generate Visualizations

Create visual plots:

```bash
python3 scripts/plot_traces.py
```

**Expected Output:**
```
==================================================
AEST800 Trace Visualization
==================================================

Generating plots...

✓ Power traces plot saved: results/power_traces.png
✓ Timing comparison plot saved: results/timing_comparison.png
✓ EM traces plot saved: results/em_traces.png
✓ Difference analysis plot saved: results/difference_analysis.png

==================================================
All plots generated successfully!
Check the results/ directory for PNG files
==================================================
```

### 5. Review the Results

Check the generated files:

```bash
ls -lh results/
```

**You should see:**
```
-rw-rw-r-- 1 user user 195K Nov 13 22:27 difference_analysis.png
-rw-rw-r-- 1 user user  59B Nov 13 22:27 em_trace_clean.csv
-rw-rw-r-- 1 user user  59B Nov 13 22:27 em_trace_trojan.csv
-rw-rw-r-- 1 user user 142K Nov 13 22:27 em_traces.png
-rw-rw-r-- 1 user user  53B Nov 13 22:27 power_trace_clean.csv
-rw-rw-r-- 1 user user  53B Nov 13 22:27 power_trace_trojan.csv
-rw-rw-r-- 1 user user 170K Nov 13 22:27 power_traces.png
-rw-rw-r-- 1 user user  87K Nov 13 22:27 timing_comparison.png
-rw-rw-r-- 1 user user  23B Nov 13 22:27 timing_trace_clean.csv
-rw-rw-r-- 1 user user  23B Nov 13 22:27 timing_trace_trojan.csv
```

### 6. Examine the Trace Data

View raw power trace data:

```bash
cat results/power_trace_clean.csv
```

**Output:**
```
Cycle, Power
1, 0
2, 400
3, 400
4, 400
5, 400
6, 560
```

Compare with trojan version:

```bash
cat results/power_trace_trojan.csv
```

**Output:**
```
Cycle, Power
1, 0
2, 400
3, 400
4, 400
5, 400
6, 800      <-- NOTICE THE SPIKE!
```

**Key Observation:** At cycle 6, the trojan causes power to spike from 560 to 800 units!

## Understanding the Results

### Power Traces
The power trace plots show power consumption over time:
- **Blue line (Clean)**: Normal AES operation
- **Orange line (Trojan)**: Trojan-infected version
- **Divergence at cycle 6**: When trojan activates and leaks power

### EM Traces
The EM trace plots show electromagnetic activity:
- Similar pattern to power traces
- Even more pronounced difference (20.39% vs 11.11%)
- Shows trojan creates detectable EM signatures

### Difference Analysis
The difference plots highlight the trojan's impact:
- **Top plot**: Power difference (Trojan - Clean)
- **Bottom plot**: EM activity difference
- Both show sharp increases when trojan is active

### Timing Comparison
Bar chart comparing execution cycles:
- Currently shows no difference (all tests take 1 cycle)
- In more complex implementations, trojan could cause timing delays

## Interpreting Trojan Behavior

### When is the Trojan Active?

The trojan activates in **Test 2** and **Test 3** because:

**Test 2:** Plaintext = `0x...ccddabcd`
- Lower 16 bits = `0xABCD` ✓ (matches trigger)

**Test 3:** Plaintext = `0x...12340000`
- Bits 16-31 = `0x1234` ✓ (matches trigger)

**Test 1:** Plaintext = `0x...ccddeeff`
- No trigger pattern ✗ (trojan stays dormant)

### What Does the Trojan Do?

When activated, the trojan:

1. **Leaks Key Information**
   - Creates switching activity correlated with key bits
   - Observable through power consumption
   - Observable through EM emissions

2. **Generates Timing Delays**
   - Accumulates delay values based on key Hamming weight
   - Could cause stalls (visible in more complex implementations)

3. **Creates Detectable Signatures**
   - Power spike at cycle 6
   - EM activity increase
   - Statistical anomalies in traces

## Advanced Usage

### Modifying Test Vectors

Edit `tb/aes128_tb.v` to add custom test cases:

```verilog
// Add after Test 3
test_num = 4;
plaintext = 128'hYOUR_PLAINTEXT_HERE;
key = 128'hYOUR_KEY_HERE;

timing_cycles_clean = 0;
timing_cycles_trojan = 0;

start = 1;
#10;
start = 0;

wait(done_clean && done_trojan);
#20;

$display("Test %0d completed:", test_num);
$display("  Clean    - Cycles: %0d, Ciphertext: %h", 
         timing_cycles_clean, ciphertext_clean);
$display("  Trojan   - Cycles: %0d, Ciphertext: %h", 
         timing_cycles_trojan, ciphertext_trojan);
$fwrite(trace_file_timing_clean, "%0d, %0d\n", test_num, timing_cycles_clean);
$fwrite(trace_file_timing_trojan, "%0d, %0d\n", test_num, timing_cycles_trojan);

#100;
```

### Changing Trojan Triggers

Edit `rtl/aes128_trojan.v` line ~28:

```verilog
// Original trigger
assign trojan_trigger = (plaintext[15:0] == 16'hABCD) || 
                        (plaintext[31:16] == 16'h1234);

// Custom trigger - activate on all zeros
assign trojan_trigger = (plaintext[31:0] == 32'h0);

// Or trigger on specific key patterns
assign trojan_trigger = (key[7:0] == 8'hFF);
```

### Creating Custom Analysis

Create a new Python script:

```python
#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt

# Read traces
power_clean = pd.read_csv('results/power_trace_clean.csv')
power_trojan = pd.read_csv('results/power_trace_trojan.csv')

# Strip whitespace
power_clean.columns = power_clean.columns.str.strip()
power_trojan.columns = power_trojan.columns.str.strip()

# Custom analysis
max_diff = (power_trojan['Power'] - power_clean['Power']).max()
print(f"Maximum power difference: {max_diff}")

# Custom plot
plt.figure(figsize=(10, 6))
plt.plot(power_trojan['Power'] / power_clean['Power'], 
         marker='o', label='Power Ratio (Trojan/Clean)')
plt.axhline(y=1.0, color='r', linestyle='--', label='No difference')
plt.xlabel('Cycle')
plt.ylabel('Power Ratio')
plt.title('Trojan Power Ratio Analysis')
plt.legend()
plt.grid(True)
plt.savefig('results/custom_analysis.png')
print("Saved: results/custom_analysis.png")
```

## Troubleshooting

### Issue: Simulation takes too long
**Solution:** The simulation should complete in ~10 seconds. If it hangs, press Ctrl+C and check for syntax errors.

### Issue: No differences in traces
**Solution:** Ensure you're looking at Tests 2 and 3 where the trojan is triggered. Test 1 should show no difference.

### Issue: Python import errors
**Solution:** Install required packages:
```bash
pip3 install matplotlib pandas numpy
```

### Issue: Permission denied on scripts
**Solution:** Make scripts executable:
```bash
chmod +x scripts/*.sh scripts/*.py
```

## Next Steps

1. **Experiment**: Try different trigger patterns and test vectors
2. **Enhance**: Make the trojan stealthier or more sophisticated
3. **Detect**: Implement machine learning-based detection
4. **Expand**: Add support for other cryptographic algorithms
5. **Deploy**: Test on real FPGA hardware

## References

- Main documentation: [README.md](../README.md)
- Quick start guide: [QUICKSTART.md](QUICKSTART.md)
- Detailed results: [RESULTS.md](RESULTS.md)

## Questions?

If you encounter issues or have questions:
1. Check the documentation in `docs/`
2. Review the source code comments in `rtl/` and `tb/`
3. Open an issue on GitHub

Happy trojan hunting! 🔍🔒
