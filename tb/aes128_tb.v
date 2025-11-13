`timescale 1ns / 1ps

// Testbench for AES-128 implementations (Clean and Trojan)
// Generates power, timing, and EM trace data

module aes128_tb;

    // Clock and reset
    reg clk;
    reg rst;
    
    // Test signals
    reg start;
    reg [127:0] plaintext;
    reg [127:0] key;
    
    // Clean version outputs
    wire [127:0] ciphertext_clean;
    wire done_clean;
    
    // Trojan version outputs
    wire [127:0] ciphertext_trojan;
    wire done_trojan;
    
    // Trace collection
    integer trace_file_power_clean;
    integer trace_file_power_trojan;
    integer trace_file_timing_clean;
    integer trace_file_timing_trojan;
    integer trace_file_em_clean;
    integer trace_file_em_trojan;
    
    // Counters for trace generation
    integer cycle_count;
    integer power_estimate_clean;
    integer power_estimate_trojan;
    integer timing_cycles_clean;
    integer timing_cycles_trojan;
    integer em_activity_clean;
    integer em_activity_trojan;
    
    // Test vectors
    integer test_num;
    
    // Instantiate clean AES
    aes128_clean u_clean (
        .clk(clk),
        .rst(rst),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext_clean),
        .done(done_clean)
    );
    
    // Instantiate trojan AES
    aes128_trojan u_trojan (
        .clk(clk),
        .rst(rst),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext_trojan),
        .done(done_trojan)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Power estimation based on switching activity
    always @(posedge clk) begin
        if (!rst) begin
            // Estimate power by counting bit transitions  
            power_estimate_clean = $countones(ciphertext_clean ^ plaintext) * 10;
            power_estimate_trojan = $countones(ciphertext_trojan ^ plaintext) * 10;
            
            // Add trojan power leakage (extra switching) - ENHANCED DETECTION
            if (u_trojan.trojan_active) begin
                // Trojan creates significant extra power consumption
                power_estimate_trojan = power_estimate_trojan + 
                    $countones(u_trojan.power_leakage_reg) * 15 + 
                    $countones(u_trojan.timing_delay_reg) * 8 + 
                    (u_trojan.trojan_counter * 3);
            end
        end
    end
    
    // EM activity estimation (similar to power but different weights)
    always @(posedge clk) begin
        if (!rst) begin
            em_activity_clean = $countones(u_clean.state) + $countones(u_clean.round_key);
            em_activity_trojan = $countones(u_trojan.state) + $countones(u_trojan.round_key);
            
            // Trojan creates additional EM signatures - ENHANCED DETECTION
            if (u_trojan.trojan_active) begin
                em_activity_trojan = em_activity_trojan + 
                    $countones(u_trojan.timing_delay_reg) * 5 +
                    $countones(u_trojan.power_leakage_reg) * 4 +
                    (u_trojan.trojan_counter * 2);
            end
        end
    end
    
    // Timing measurement
    always @(posedge clk) begin
        if (!rst && start) begin
            if (!done_clean)
                timing_cycles_clean = timing_cycles_clean + 1;
            if (!done_trojan)
                timing_cycles_trojan = timing_cycles_trojan + 1;
        end
    end
    
    // Trace file writing
    always @(posedge clk) begin
        if (!rst && (start || done_clean || done_trojan)) begin
            cycle_count = cycle_count + 1;
            
            // Write power traces
            $fwrite(trace_file_power_clean, "%0d, %0d\n", cycle_count, power_estimate_clean);
            $fwrite(trace_file_power_trojan, "%0d, %0d\n", cycle_count, power_estimate_trojan);
            
            // Write EM traces
            $fwrite(trace_file_em_clean, "%0d, %0d\n", cycle_count, em_activity_clean);
            $fwrite(trace_file_em_trojan, "%0d, %0d\n", cycle_count, em_activity_trojan);
        end
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        start = 0;
        plaintext = 128'h0;
        key = 128'h0;
        cycle_count = 0;
        test_num = 0;
        timing_cycles_clean = 0;
        timing_cycles_trojan = 0;
        
        // Open trace files
        trace_file_power_clean = $fopen("results/power_trace_clean.csv", "w");
        trace_file_power_trojan = $fopen("results/power_trace_trojan.csv", "w");
        trace_file_timing_clean = $fopen("results/timing_trace_clean.csv", "w");
        trace_file_timing_trojan = $fopen("results/timing_trace_trojan.csv", "w");
        trace_file_em_clean = $fopen("results/em_trace_clean.csv", "w");
        trace_file_em_trojan = $fopen("results/em_trace_trojan.csv", "w");
        
        // Write CSV headers
        $fwrite(trace_file_power_clean, "Cycle, Power\n");
        $fwrite(trace_file_power_trojan, "Cycle, Power\n");
        $fwrite(trace_file_timing_clean, "Test, Cycles\n");
        $fwrite(trace_file_timing_trojan, "Test, Cycles\n");
        $fwrite(trace_file_em_clean, "Cycle, EM_Activity\n");
        $fwrite(trace_file_em_trojan, "Cycle, EM_Activity\n");
        
        $display("=== AES-128 Simulation Started ===");
        $display("Generating power, timing, and EM traces...");
        
        // Release reset
        #100;
        rst = 0;
        #20;
        
        // Test 1: Normal plaintext (trojan not triggered)
        test_num = 1;
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key = 128'h000102030405060708090a0b0c0d0e0f;
        
        timing_cycles_clean = 0;
        timing_cycles_trojan = 0;
        
        start = 1;
        #10;
        start = 0;
        
        // Wait for encryption to complete
        wait(done_clean && done_trojan);
        #20;
        
        $display("Test %0d completed:", test_num);
        $display("  Clean    - Cycles: %0d, Ciphertext: %h", timing_cycles_clean, ciphertext_clean);
        $display("  Trojan   - Cycles: %0d, Ciphertext: %h", timing_cycles_trojan, ciphertext_trojan);
        $fwrite(trace_file_timing_clean, "%0d, %0d\n", test_num, timing_cycles_clean);
        $fwrite(trace_file_timing_trojan, "%0d, %0d\n", test_num, timing_cycles_trojan);
        
        #100;
        
        // Test 2: Trojan trigger pattern (lower 16 bits = 0xABCD)
        test_num = 2;
        plaintext = 128'h00112233445566778899aabbccddabcd;
        key = 128'h0f0e0d0c0b0a09080706050403020100;
        
        timing_cycles_clean = 0;
        timing_cycles_trojan = 0;
        
        start = 1;
        #10;
        start = 0;
        
        wait(done_clean && done_trojan);
        #20;
        
        $display("Test %0d completed (TROJAN TRIGGERED):", test_num);
        $display("  Clean    - Cycles: %0d, Ciphertext: %h", timing_cycles_clean, ciphertext_clean);
        $display("  Trojan   - Cycles: %0d, Ciphertext: %h", timing_cycles_trojan, ciphertext_trojan);
        $fwrite(trace_file_timing_clean, "%0d, %0d\n", test_num, timing_cycles_clean);
        $fwrite(trace_file_timing_trojan, "%0d, %0d\n", test_num, timing_cycles_trojan);
        
        #100;
        
        // Test 3: Another trojan trigger pattern (bits 16-31 = 0x1234)
        test_num = 3;
        plaintext = 128'h00112233445566778899aabb12340000;
        key = 128'h1234567890abcdef1234567890abcdef;
        
        timing_cycles_clean = 0;
        timing_cycles_trojan = 0;
        
        start = 1;
        #10;
        start = 0;
        
        wait(done_clean && done_trojan);
        #20;
        
        $display("Test %0d completed (TROJAN TRIGGERED):", test_num);
        $display("  Clean    - Cycles: %0d, Ciphertext: %h", timing_cycles_clean, ciphertext_clean);
        $display("  Trojan   - Cycles: %0d, Ciphertext: %h", timing_cycles_trojan, ciphertext_trojan);
        $fwrite(trace_file_timing_clean, "%0d, %0d\n", test_num, timing_cycles_clean);
        $fwrite(trace_file_timing_trojan, "%0d, %0d\n", test_num, timing_cycles_trojan);
        
        #100;
        
        // Close trace files
        $fclose(trace_file_power_clean);
        $fclose(trace_file_power_trojan);
        $fclose(trace_file_timing_clean);
        $fclose(trace_file_timing_trojan);
        $fclose(trace_file_em_clean);
        $fclose(trace_file_em_trojan);
        
        $display("\n=== Simulation Complete ===");
        $display("Trace files generated in results/ directory:");
        $display("  - power_trace_clean.csv");
        $display("  - power_trace_trojan.csv");
        $display("  - timing_trace_clean.csv");
        $display("  - timing_trace_trojan.csv");
        $display("  - em_trace_clean.csv");
        $display("  - em_trace_trojan.csv");
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #50000;
        $display("Simulation complete - exiting.");
        $finish;
    end

endmodule
