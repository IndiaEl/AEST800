# AEST800 Trojan Simulation Results Summary

## Overview
This document summarizes the results from the AEST800 hardware trojan simulation framework.

## Simulation Configuration
- **Test Cases**: 3 encryption operations
- **Trojan Triggers**: 
  - Test 1: No trigger (normal operation)
  - Test 2: Triggered by plaintext pattern `0xABCD` in lower 16 bits
  - Test 3: Triggered by plaintext pattern `0x1234` in bits 16-31

## Detection Results

### Power Analysis
- **Clean Implementation**:
  - Mean Power: 360.00 units
  - Std Deviation: 187.62
  - Max Power: 560.00 units

- **Trojan-Infected Implementation**:
  - Mean Power: 400.00 units
  - Std Deviation: 252.98
  - Max Power: 800.00 units

- **Detection Metrics**:
  - Power Overhead: **11.11% increase**
  - Absolute Difference: 40.00 units
  - Correlation: 0.9439
  - **Status: ⚠ ANOMALY DETECTED**

### Timing Analysis
- **Clean Implementation**: 1 cycle average
- **Trojan-Infected Implementation**: 1 cycle average
- **Detection Metrics**:
  - Timing Overhead: 0.00%
  - **Status: ✓ Normal**

### Electromagnetic (EM) Analysis
- **Clean Implementation**:
  - Mean EM Activity: 93.17 units
  - Std Deviation: 45.68
  - Max Activity: 115.00 units

- **Trojan-Infected Implementation**:
  - Mean EM Activity: 112.17 units
  - Std Deviation: 72.44
  - Max Activity: 229.00 units

- **Detection Metrics**:
  - EM Overhead: **20.39% increase**
  - Absolute Difference: 19.00 units
  - Detection SNR: 0.4472
  - **Status: ⚠ ANOMALY DETECTED**

## Trojan Detection Conclusion

**⚠⚠⚠ HARDWARE TROJAN LIKELY PRESENT ⚠⚠⚠**

**Detection Score: 2/3 methods show anomalies**

The trojan is successfully detected through:
1. ✓ Power consumption analysis (11.11% increase)
2. ✓ EM emission analysis (20.39% increase)
3. ✗ Timing analysis showed no significant difference in this simplified implementation

## Trojan Characteristics

### Trigger Mechanism
The AEST800 trojan activates when specific patterns appear in the plaintext input:
- Pattern 1: `plaintext[15:0] == 0xABCD`
- Pattern 2: `plaintext[31:16] == 0x1234`

### Payload Effects
When triggered, the trojan:

1. **Power Leakage**:
   - Creates additional switching activity in `power_leakage_reg` (32-bit)
   - Toggles bits based on key values
   - Increments a counter correlated with key bits

2. **Timing Variations**:
   - Accumulates delay values in `timing_delay_reg` (16-bit)
   - Delay proportional to Hamming weight of key segments
   - Can cause stall cycles during encryption

3. **EM Signatures**:
   - Extra electromagnetic emissions from trojan registers
   - Detectable through EM probing or analysis

## Key Findings

### Cycle-by-Cycle Analysis
The most significant trojan activity occurs at **Clock Cycle 6**:
- Power: Clean=560 units → Trojan=800 units (**+42.9%**)
- EM Activity: Clean=115 units → Trojan=229 units (**+99.1%**)

This represents the peak of trojan operation when it actively leaks key information.

### Detection Feasibility
The trojan is **easily detectable** with the current implementation:
- Power analysis provides clear separation
- EM analysis shows even stronger signals
- Multiple detection methods agree on presence of anomaly

## Implications for Hardware Security

### Attack Scenario
An attacker who can:
1. Control input plaintexts
2. Measure power or EM emissions
3. Correlate measurements with key bits

Could potentially extract secret key information when the trojan is triggered.

### Defense Recommendations
1. **Power/EM Monitoring**: Deploy runtime monitoring for abnormal consumption
2. **Formal Verification**: Use formal methods to verify RTL against specifications
3. **Logic Testing**: Test for unused or anomalous circuitry
4. **Side-Channel Hardening**: Implement countermeasures (masking, hiding)

## File Outputs

### Generated Traces (CSV)
- `results/power_trace_clean.csv` - Power consumption of clean AES
- `results/power_trace_trojan.csv` - Power consumption with trojan
- `results/timing_trace_clean.csv` - Execution cycles for clean AES
- `results/timing_trace_trojan.csv` - Execution cycles with trojan
- `results/em_trace_clean.csv` - EM emissions from clean AES
- `results/em_trace_trojan.csv` - EM emissions with trojan

### Visualization Plots (PNG)
- `results/power_traces.png` - Power comparison plot
- `results/timing_comparison.png` - Timing comparison bar chart
- `results/em_traces.png` - EM comparison plot
- `results/difference_analysis.png` - Differential analysis plots

## Reproducibility

To reproduce these results:
```bash
./scripts/run_simulation.sh
python3 scripts/analyze_traces.py
python3 scripts/plot_traces.py
```

## Educational Value

This simulation framework demonstrates:
- Hardware trojan insertion techniques
- Side-channel leakage mechanisms
- Multiple detection methodologies
- Real-world security implications

Perfect for:
- Hardware security courses
- Trojan detection research
- RTL security training
- Side-channel analysis education

## Future Enhancements

Potential improvements to the framework:
1. More sophisticated AES implementation (full 10 rounds)
2. Stealthier trojan designs (lower detection rates)
3. Machine learning-based detection
4. Support for other cryptographic algorithms
5. Hardware implementation and testing on FPGA
6. More realistic trigger conditions
7. Advanced statistical analysis techniques

---

**Date**: 2025-11-13  
**Framework Version**: 1.0  
**Simulator**: Icarus Verilog 12.0
