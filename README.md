# AEST800 Trojan Simulation Framework

A comprehensive framework for simulating and analyzing hardware trojans in AES-128 encryption circuits. This project generates power, timing, and electromagnetic (EM) traces to demonstrate the detection of hardware trojans through side-channel analysis.

## Overview

This framework includes:
- **Clean AES-128 Implementation**: Trojan-free AES encryption core
- **Trojan-Infected AES-128**: AES core with AEST800 hardware trojan
- **Simulation Environment**: Comprehensive testbench for trace generation
- **Analysis Tools**: Python scripts for visualization and statistical analysis

## AEST800 Trojan Description

The AEST800 trojan is a hardware trojan designed to:

1. **Trigger Mechanism**: Activates on specific plaintext patterns
   - Trigger pattern 1: Lower 16 bits = `0xABCD`
   - Trigger pattern 2: Bits 16-31 = `0x1234`

2. **Payload Effects**:
   - **Power Leakage**: Creates additional switching activity correlated with secret key bits
   - **Timing Variations**: Introduces delays proportional to Hamming weight of key segments
   - **EM Signatures**: Generates detectable electromagnetic emissions

3. **Detection**: The trojan is detectable through:
   - Power trace analysis (increased consumption during activation)
   - Timing analysis (variable execution cycles)
   - EM signature analysis (abnormal emission patterns)

## Directory Structure

```
AEST800/
├── rtl/                    # RTL source files
│   ├── aes128_clean.v      # Clean AES-128 implementation
│   └── aes128_trojan.v     # Trojan-infected AES-128
├── tb/                     # Testbenches
│   └── aes128_tb.v         # Main testbench with trace generation
├── scripts/                # Automation scripts
│   ├── run_simulation.sh   # Main simulation script
│   ├── plot_traces.py      # Trace visualization
│   └── analyze_traces.py   # Statistical analysis
├── results/                # Generated trace files and plots
└── docs/                   # Documentation
```

## Prerequisites

### Required Tools
- **Icarus Verilog** (iverilog): For Verilog simulation
- **Python 3.x**: For analysis and visualization
- **Python packages**:
  - matplotlib
  - pandas
  - numpy

### Installation

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install iverilog python3 python3-pip
pip3 install matplotlib pandas numpy
```

#### macOS
```bash
brew install icarus-verilog python3
pip3 install matplotlib pandas numpy
```

#### Windows
1. Install [Icarus Verilog for Windows](http://bleyer.org/icarus/)
2. Install [Python 3](https://www.python.org/downloads/)
3. Install Python packages:
   ```
   pip install matplotlib pandas numpy
   ```

## Quick Start

### 1. Run the Simulation

```bash
./scripts/run_simulation.sh
```

This will:
- Compile the Verilog sources
- Run the simulation with multiple test vectors
- Generate trace files in `results/` directory

### 2. Visualize the Traces

```bash
python3 scripts/plot_traces.py
```

This generates:
- `results/power_traces.png` - Power consumption comparison
- `results/timing_comparison.png` - Execution cycle comparison
- `results/em_traces.png` - EM activity comparison
- `results/difference_analysis.png` - Differential analysis

### 3. Analyze the Results

```bash
python3 scripts/analyze_traces.py
```

This provides:
- Statistical analysis of power, timing, and EM traces
- Anomaly detection metrics
- Trojan detection summary

## Generated Trace Files

The simulation produces the following CSV files in `results/`:

- `power_trace_clean.csv` - Power consumption of clean implementation
- `power_trace_trojan.csv` - Power consumption of trojan-infected implementation
- `timing_trace_clean.csv` - Execution cycles for clean implementation
- `timing_trace_trojan.csv` - Execution cycles for trojan-infected implementation
- `em_trace_clean.csv` - EM activity of clean implementation
- `em_trace_trojan.csv` - EM activity of trojan-infected implementation

## Test Vectors

The testbench runs multiple test cases:

1. **Test 1**: Normal plaintext (trojan not triggered)
   - Plaintext: `0x00112233445566778899aabbccddeeff`
   - Key: `0x000102030405060708090a0b0c0d0e0f`

2. **Test 2**: Trojan trigger pattern (lower 16 bits = 0xABCD)
   - Plaintext: `0x00112233445566778899aabbccddabcd`
   - Key: `0x0f0e0d0c0b0a09080706050403020100`

3. **Test 3**: Trojan trigger pattern (bits 16-31 = 0x1234)
   - Plaintext: `0x00112233445566778899aabb12340000`
   - Key: `0x1234567890abcdef1234567890abcdef`

4. **Test 4**: Different key, no trigger
   - Plaintext: `0xffeeddccbbaa99887766554433221100`
   - Key: `0xfedcba0987654321fedcba0987654321`

## Understanding the Results

### Power Analysis
- **Normal Operation**: Consistent power consumption across operations
- **Trojan Active**: Increased power consumption due to extra switching activity
- **Detection Metric**: >5% increase indicates potential trojan

### Timing Analysis
- **Normal Operation**: Fixed execution cycles (10-15 cycles)
- **Trojan Active**: Variable execution cycles based on key-dependent delays
- **Detection Metric**: >2% overhead indicates timing anomalies

### EM Analysis
- **Normal Operation**: Baseline EM activity from normal circuit switching
- **Trojan Active**: Additional EM signatures from trojan circuits
- **Detection Metric**: >5% increase in EM activity

## Educational Use

This framework is designed for:
- **Hardware Security Education**: Understanding hardware trojan mechanisms
- **Side-Channel Analysis**: Learning power, timing, and EM analysis techniques
- **Trojan Detection Research**: Developing and testing detection methodologies
- **RTL Security**: Understanding security implications at the RTL level

## Customization

### Adding New Test Vectors
Edit `tb/aes128_tb.v` and add new test cases in the initial block:
```verilog
test_num = 5;
plaintext = 128'h<your_plaintext>;
key = 128'h<your_key>;
start = 1;
#10;
start = 0;
```

### Modifying Trojan Behavior
Edit `rtl/aes128_trojan.v`:
- Change trigger pattern in `assign trojan_trigger = ...`
- Modify power leakage logic in the power leakage always block
- Adjust timing delays in the timing delay mechanism

### Custom Analysis
Create new Python scripts in `scripts/` directory using pandas to read the CSV files and perform custom analysis.

## Limitations

This is a **simplified educational implementation**:
- AES implementation is simplified (not NIST-compliant)
- S-box is reduced for demonstration
- Key schedule is simplified
- Trojan is deliberately detectable for educational purposes

For production or research use, consider using:
- Full NIST-compliant AES implementations
- More sophisticated trojans with stealthier characteristics
- Advanced detection algorithms (machine learning, statistical tests)

## References

- NIST AES Standard: [FIPS 197](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf)
- Hardware Trojans: "Hardware Trojan Detection: A Critical Review" (IEEE, 2020)
- Side-Channel Analysis: "Power Analysis Attacks" by Kocher et al.

## License

This is an educational project. Use responsibly and for learning purposes.

## Contributing

Contributions are welcome! Areas for improvement:
- More sophisticated trojan implementations
- Additional detection algorithms
- Machine learning-based analysis
- Support for other cryptographic algorithms

## Troubleshooting

### Simulation fails
- Ensure Icarus Verilog is installed: `iverilog -v`
- Check Verilog syntax errors in compilation output

### Python scripts fail
- Install required packages: `pip3 install matplotlib pandas numpy`
- Ensure simulation ran successfully and CSV files exist in `results/`

### No visible differences in traces
- Try test cases with trigger patterns (Test 2 and 3)
- Increase simulation time or number of test vectors
- Adjust trojan sensitivity parameters in `aes128_trojan.v`

## Contact

For questions, issues, or contributions, please open an issue on GitHub.