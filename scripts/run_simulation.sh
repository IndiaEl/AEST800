#!/bin/bash
# Simulation script for AES-128 with trace generation
# Uses Icarus Verilog for simulation

echo "==================================="
echo "AEST800 Trojan Simulation Framework"
echo "==================================="
echo ""

# Check if iverilog is installed
if ! command -v iverilog &> /dev/null; then
    echo "Error: Icarus Verilog (iverilog) is not installed."
    echo "Please install it using:"
    echo "  Ubuntu/Debian: sudo apt-get install iverilog"
    echo "  macOS: brew install icarus-verilog"
    exit 1
fi

# Create results directory if it doesn't exist
mkdir -p results

echo "Step 1: Compiling Verilog sources..."
iverilog -o sim_aes128 \
    -g2012 \
    rtl/aes128_clean.v \
    rtl/aes128_trojan.v \
    tb/aes128_tb.v

if [ $? -ne 0 ]; then
    echo "Error: Compilation failed!"
    exit 1
fi

echo "Step 2: Running simulation..."
vvp sim_aes128

if [ $? -ne 0 ]; then
    echo "Error: Simulation failed!"
    exit 1
fi

echo ""
echo "Step 3: Simulation complete!"
echo ""
echo "Generated trace files:"
ls -lh results/*.csv

echo ""
echo "==================================="
echo "Use Python scripts to visualize traces:"
echo "  python3 scripts/plot_traces.py"
echo "  python3 scripts/analyze_traces.py"
echo "==================================="
