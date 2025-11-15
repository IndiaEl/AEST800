#!/usr/bin/env python3
"""
Power, Timing, and EM Trace Visualization
Compares clean and trojan-infected AES implementations
"""

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os
import sys

def plot_power_traces():
    """Plot power consumption traces"""
    try:
        # Read power traces
        power_clean = pd.read_csv('results/power_trace_clean.csv')
        power_trojan = pd.read_csv('results/power_trace_trojan.csv')
        
        # Strip whitespace from column names
        power_clean.columns = power_clean.columns.str.strip()
        power_trojan.columns = power_trojan.columns.str.strip()
        
        plt.figure(figsize=(14, 5))
        plt.plot(power_clean['Cycle'], power_clean['Power'], 
                label='Clean (No Trojan)', alpha=0.7, linewidth=1.5)
        plt.plot(power_trojan['Cycle'], power_trojan['Power'], 
                label='Trojan-Infected', alpha=0.7, linewidth=1.5)
        plt.xlabel('Clock Cycle')
        plt.ylabel('Power Consumption (Arbitrary Units)')
        plt.title('Power Trace Comparison: Clean vs Trojan-Infected AES-128')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.savefig('results/power_traces.png', dpi=300)
        print("✓ Power traces plot saved: results/power_traces.png")
        plt.close()
        
    except Exception as e:
        print(f"✗ Error plotting power traces: {e}")

def plot_timing_comparison():
    """Plot timing comparison"""
    try:
        # Read timing traces
        timing_clean = pd.read_csv('results/timing_trace_clean.csv')
        timing_trojan = pd.read_csv('results/timing_trace_trojan.csv')
        
        # Strip whitespace from column names
        timing_clean.columns = timing_clean.columns.str.strip()
        timing_trojan.columns = timing_trojan.columns.str.strip()
        
        plt.figure(figsize=(10, 6))
        x = np.arange(len(timing_clean))
        width = 0.35
        
        plt.bar(x - width/2, timing_clean['Cycles'], width, 
                label='Clean', alpha=0.8)
        plt.bar(x + width/2, timing_trojan['Cycles'], width, 
                label='Trojan', alpha=0.8)
        
        plt.xlabel('Test Number')
        plt.ylabel('Execution Cycles')
        plt.title('Timing Comparison: Clean vs Trojan-Infected AES-128')
        plt.xticks(x, timing_clean['Test'])
        plt.legend()
        plt.grid(True, alpha=0.3, axis='y')
        plt.tight_layout()
        plt.savefig('results/timing_comparison.png', dpi=300)
        print("✓ Timing comparison plot saved: results/timing_comparison.png")
        plt.close()
        
    except Exception as e:
        print(f"✗ Error plotting timing comparison: {e}")

def plot_em_traces():
    """Plot electromagnetic emission traces"""
    try:
        # Read EM traces
        em_clean = pd.read_csv('results/em_trace_clean.csv')
        em_trojan = pd.read_csv('results/em_trace_trojan.csv')
        
        # Strip whitespace from column names
        em_clean.columns = em_clean.columns.str.strip()
        em_trojan.columns = em_trojan.columns.str.strip()
        
        plt.figure(figsize=(14, 5))
        plt.plot(em_clean['Cycle'], em_clean['EM_Activity'], 
                label='Clean (No Trojan)', alpha=0.7, linewidth=1.5)
        plt.plot(em_trojan['Cycle'], em_trojan['EM_Activity'], 
                label='Trojan-Infected', alpha=0.7, linewidth=1.5)
        plt.xlabel('Clock Cycle')
        plt.ylabel('EM Activity (Arbitrary Units)')
        plt.title('EM Trace Comparison: Clean vs Trojan-Infected AES-128')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.savefig('results/em_traces.png', dpi=300)
        print("✓ EM traces plot saved: results/em_traces.png")
        plt.close()
        
    except Exception as e:
        print(f"✗ Error plotting EM traces: {e}")

def plot_difference_analysis():
    """Plot difference between clean and trojan traces"""
    try:
        # Read traces
        power_clean = pd.read_csv('results/power_trace_clean.csv')
        power_trojan = pd.read_csv('results/power_trace_trojan.csv')
        em_clean = pd.read_csv('results/em_trace_clean.csv')
        em_trojan = pd.read_csv('results/em_trace_trojan.csv')
        
        # Strip whitespace from column names
        power_clean.columns = power_clean.columns.str.strip()
        power_trojan.columns = power_trojan.columns.str.strip()
        em_clean.columns = em_clean.columns.str.strip()
        em_trojan.columns = em_trojan.columns.str.strip()
        
        # Calculate differences
        power_diff = power_trojan['Power'].values - power_clean['Power'].values
        em_diff = em_trojan['EM_Activity'].values - em_clean['EM_Activity'].values
        
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 8))
        
        # Power difference
        ax1.plot(power_clean['Cycle'], power_diff, color='red', alpha=0.7)
        ax1.axhline(y=0, color='black', linestyle='--', linewidth=0.8)
        ax1.set_xlabel('Clock Cycle')
        ax1.set_ylabel('Power Difference')
        ax1.set_title('Power Consumption Difference (Trojan - Clean)')
        ax1.grid(True, alpha=0.3)
        
        # EM difference
        ax2.plot(em_clean['Cycle'], em_diff, color='orange', alpha=0.7)
        ax2.axhline(y=0, color='black', linestyle='--', linewidth=0.8)
        ax2.set_xlabel('Clock Cycle')
        ax2.set_ylabel('EM Activity Difference')
        ax2.set_title('EM Activity Difference (Trojan - Clean)')
        ax2.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig('results/difference_analysis.png', dpi=300)
        print("✓ Difference analysis plot saved: results/difference_analysis.png")
        plt.close()
        
    except Exception as e:
        print(f"✗ Error plotting difference analysis: {e}")

def main():
    print("=" * 50)
    print("AEST800 Trace Visualization")
    print("=" * 50)
    print()
    
    # Check if results directory exists
    if not os.path.exists('results'):
        print("✗ Error: results/ directory not found!")
        print("  Please run the simulation first: ./scripts/run_simulation.sh")
        sys.exit(1)
    
    # Check if trace files exist
    required_files = [
        'results/power_trace_clean.csv',
        'results/power_trace_trojan.csv',
        'results/timing_trace_clean.csv',
        'results/timing_trace_trojan.csv',
        'results/em_trace_clean.csv',
        'results/em_trace_trojan.csv'
    ]
    
    for file in required_files:
        if not os.path.exists(file):
            print(f"✗ Error: {file} not found!")
            print("  Please run the simulation first: ./scripts/run_simulation.sh")
            sys.exit(1)
    
    print("Generating plots...\n")
    
    plot_power_traces()
    plot_timing_comparison()
    plot_em_traces()
    plot_difference_analysis()
    
    print("\n" + "=" * 50)
    print("All plots generated successfully!")
    print("Check the results/ directory for PNG files")
    print("=" * 50)

if __name__ == "__main__":
    main()
