#!/usr/bin/env python3
"""
Statistical Analysis of Power, Timing, and EM Traces
Detects anomalies and quantifies trojan impact
"""

import pandas as pd
import numpy as np
import sys
import os

def analyze_power_traces():
    """Analyze power consumption traces"""
    print("\n" + "="*60)
    print("POWER TRACE ANALYSIS")
    print("="*60)
    
    try:
        power_clean = pd.read_csv('results/power_trace_clean.csv')
        power_trojan = pd.read_csv('results/power_trace_trojan.csv')
        
        # Strip whitespace from column names
        power_clean.columns = power_clean.columns.str.strip()
        power_trojan.columns = power_trojan.columns.str.strip()
        
        clean_mean = power_clean['Power'].mean()
        clean_std = power_clean['Power'].std()
        trojan_mean = power_trojan['Power'].mean()
        trojan_std = power_trojan['Power'].std()
        
        print(f"\nClean Implementation:")
        print(f"  Mean Power:      {clean_mean:.2f}")
        print(f"  Std Deviation:   {clean_std:.2f}")
        print(f"  Min Power:       {power_clean['Power'].min():.2f}")
        print(f"  Max Power:       {power_clean['Power'].max():.2f}")
        
        print(f"\nTrojan-Infected Implementation:")
        print(f"  Mean Power:      {trojan_mean:.2f}")
        print(f"  Std Deviation:   {trojan_std:.2f}")
        print(f"  Min Power:       {power_trojan['Power'].min():.2f}")
        print(f"  Max Power:       {power_trojan['Power'].max():.2f}")
        
        power_increase = ((trojan_mean - clean_mean) / clean_mean) * 100
        print(f"\nPower Overhead:")
        print(f"  Mean increase:   {power_increase:.2f}%")
        print(f"  Absolute diff:   {trojan_mean - clean_mean:.2f}")
        
        # Calculate correlation
        if len(power_clean) == len(power_trojan):
            correlation = np.corrcoef(power_clean['Power'], power_trojan['Power'])[0, 1]
            print(f"  Correlation:     {correlation:.4f}")
            
        return {
            'clean_mean': clean_mean,
            'trojan_mean': trojan_mean,
            'power_increase_pct': power_increase
        }
        
    except Exception as e:
        print(f"✗ Error analyzing power traces: {e}")
        return None

def analyze_timing_traces():
    """Analyze timing differences"""
    print("\n" + "="*60)
    print("TIMING ANALYSIS")
    print("="*60)
    
    try:
        timing_clean = pd.read_csv('results/timing_trace_clean.csv')
        timing_trojan = pd.read_csv('results/timing_trace_trojan.csv')
        
        # Strip whitespace from column names
        timing_clean.columns = timing_clean.columns.str.strip()
        timing_trojan.columns = timing_trojan.columns.str.strip()
        
        print(f"\nTest-by-Test Comparison:")
        print(f"{'Test':<6} {'Clean':<10} {'Trojan':<10} {'Diff':<10} {'% Overhead'}")
        print("-" * 60)
        
        total_overhead = 0
        for i in range(len(timing_clean)):
            test_num = timing_clean.loc[i, 'Test']
            clean_cycles = timing_clean.loc[i, 'Cycles']
            trojan_cycles = timing_trojan.loc[i, 'Cycles']
            diff = trojan_cycles - clean_cycles
            overhead = (diff / clean_cycles) * 100 if clean_cycles > 0 else 0
            total_overhead += overhead
            
            print(f"{test_num:<6} {clean_cycles:<10} {trojan_cycles:<10} "
                  f"{diff:<10} {overhead:>6.2f}%")
        
        avg_overhead = total_overhead / len(timing_clean)
        print("-" * 60)
        print(f"Average Timing Overhead: {avg_overhead:.2f}%")
        
        clean_mean = timing_clean['Cycles'].mean()
        trojan_mean = timing_trojan['Cycles'].mean()
        
        print(f"\nSummary:")
        print(f"  Clean avg cycles:    {clean_mean:.2f}")
        print(f"  Trojan avg cycles:   {trojan_mean:.2f}")
        print(f"  Avg cycle overhead:  {trojan_mean - clean_mean:.2f}")
        
        return {
            'clean_mean': clean_mean,
            'trojan_mean': trojan_mean,
            'avg_overhead_pct': avg_overhead
        }
        
    except Exception as e:
        print(f"✗ Error analyzing timing traces: {e}")
        return None

def analyze_em_traces():
    """Analyze electromagnetic emission traces"""
    print("\n" + "="*60)
    print("ELECTROMAGNETIC EMISSION ANALYSIS")
    print("="*60)
    
    try:
        em_clean = pd.read_csv('results/em_trace_clean.csv')
        em_trojan = pd.read_csv('results/em_trace_trojan.csv')
        
        # Strip whitespace from column names
        em_clean.columns = em_clean.columns.str.strip()
        em_trojan.columns = em_trojan.columns.str.strip()
        
        clean_mean = em_clean['EM_Activity'].mean()
        clean_std = em_clean['EM_Activity'].std()
        trojan_mean = em_trojan['EM_Activity'].mean()
        trojan_std = em_trojan['EM_Activity'].std()
        
        print(f"\nClean Implementation:")
        print(f"  Mean EM Activity:    {clean_mean:.2f}")
        print(f"  Std Deviation:       {clean_std:.2f}")
        print(f"  Min Activity:        {em_clean['EM_Activity'].min():.2f}")
        print(f"  Max Activity:        {em_clean['EM_Activity'].max():.2f}")
        
        print(f"\nTrojan-Infected Implementation:")
        print(f"  Mean EM Activity:    {trojan_mean:.2f}")
        print(f"  Std Deviation:       {trojan_std:.2f}")
        print(f"  Min Activity:        {em_trojan['EM_Activity'].min():.2f}")
        print(f"  Max Activity:        {em_trojan['EM_Activity'].max():.2f}")
        
        em_increase = ((trojan_mean - clean_mean) / clean_mean) * 100
        print(f"\nEM Signature Changes:")
        print(f"  Mean increase:       {em_increase:.2f}%")
        print(f"  Absolute diff:       {trojan_mean - clean_mean:.2f}")
        
        # Calculate signal-to-noise ratio for detection
        em_diff = em_trojan['EM_Activity'].values - em_clean['EM_Activity'].values
        snr = np.mean(np.abs(em_diff)) / np.std(em_diff) if np.std(em_diff) > 0 else 0
        print(f"  Detection SNR:       {snr:.4f}")
        
        return {
            'clean_mean': clean_mean,
            'trojan_mean': trojan_mean,
            'em_increase_pct': em_increase,
            'snr': snr
        }
        
    except Exception as e:
        print(f"✗ Error analyzing EM traces: {e}")
        return None

def generate_detection_report(power_stats, timing_stats, em_stats):
    """Generate trojan detection report"""
    print("\n" + "="*60)
    print("TROJAN DETECTION SUMMARY")
    print("="*60)
    
    print("\nDetection Indicators:")
    
    # Power-based detection
    if power_stats and power_stats['power_increase_pct'] > 5:
        print(f"  ⚠ Power Analysis:    ANOMALY DETECTED ({power_stats['power_increase_pct']:.2f}% increase)")
    else:
        print(f"  ✓ Power Analysis:    Normal")
    
    # Timing-based detection
    if timing_stats and timing_stats['avg_overhead_pct'] > 2:
        print(f"  ⚠ Timing Analysis:   ANOMALY DETECTED ({timing_stats['avg_overhead_pct']:.2f}% overhead)")
    else:
        print(f"  ✓ Timing Analysis:   Normal")
    
    # EM-based detection
    if em_stats and em_stats['em_increase_pct'] > 5:
        print(f"  ⚠ EM Analysis:       ANOMALY DETECTED ({em_stats['em_increase_pct']:.2f}% increase)")
    else:
        print(f"  ✓ EM Analysis:       Normal")
    
    print("\nConclusion:")
    anomaly_count = 0
    if power_stats and power_stats['power_increase_pct'] > 5:
        anomaly_count += 1
    if timing_stats and timing_stats['avg_overhead_pct'] > 2:
        anomaly_count += 1
    if em_stats and em_stats['em_increase_pct'] > 5:
        anomaly_count += 1
    
    if anomaly_count >= 2:
        print("  ⚠⚠⚠ HARDWARE TROJAN LIKELY PRESENT ⚠⚠⚠")
        print(f"  {anomaly_count}/3 detection methods show anomalies")
    elif anomaly_count == 1:
        print("  ⚠ Suspicious activity detected - further analysis recommended")
    else:
        print("  ✓ No significant anomalies detected")

def main():
    print("=" * 60)
    print("AEST800 TROJAN TRACE ANALYSIS")
    print("=" * 60)
    
    # Check if results directory exists
    if not os.path.exists('results'):
        print("\n✗ Error: results/ directory not found!")
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
            print(f"\n✗ Error: {file} not found!")
            print("  Please run the simulation first: ./scripts/run_simulation.sh")
            sys.exit(1)
    
    # Run analyses
    power_stats = analyze_power_traces()
    timing_stats = analyze_timing_traces()
    em_stats = analyze_em_traces()
    
    # Generate detection report
    generate_detection_report(power_stats, timing_stats, em_stats)
    
    print("\n" + "=" * 60)
    print("Analysis complete!")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()
