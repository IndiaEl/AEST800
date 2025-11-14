`timescale 1ns / 1ps

/*
This is the TOP-LEVEL module for the CW305 board.
It connects the aes_128 core to the physical pins:
- 'sysclk' and 'rst' from the board
- 'btn[3:0]' as inputs (Pmod J)
- 'led[3:0]' as outputs (Pmod J)
- 'trigger' as an output (Pmod K)
*/

module cw305_aes_top(
    input wire sysclk, // Main system clock (100MHz from pin N11)
    input wire rst,    // Reset (from pin C4)
    input wire [3:0] btn, // 4 buttons (from Pmod J)
    output reg [3:0] led, // 4 LEDs (on Pmod J)
    output reg trigger    // Trigger pulse for oscilloscope
    );

    // Wires and registers for internal connections
    wire [127:0] ciphertext_wire; // Output from aes_128
    reg  [127:0] plaintext_reg;   // Input to aes_128
    reg  [127:0] key_reg;         // Input to aes_128
    reg  [127:0] captured_output; // Latched output for LEDs
    
    // --- Instantiate your AES-128 Core ---
    // (This 'aes_128' module is defined in your aes_128.v file)
    aes_128 uut (
        .clk(sysclk),             // Connect core's clock
        .state(plaintext_reg),    // Connect core's plaintext input
        .key(key_reg),            // Connect core's key input
        .out(ciphertext_wire)     // Connect core's ciphertext output
    );

    // --- Button Debouncing and Edge Detection ---
    reg [3:0] btn_sync_0, btn_sync_1, btn_prev;
    wire btn0_rising_edge, btn1_rising_edge, btn2_rising_edge, btn3_rising_edge;

    always @(posedge sysclk) begin
       btn_sync_0 <= btn;
       btn_sync_1 <= btn_sync_0;
    end

    always @(posedge sysclk or posedge rst) begin
       if(rst)
           btn_prev <= 4'b0000;
       else
           btn_prev <= btn_sync_1;
    end

    assign btn0_rising_edge = btn_sync_1[0] & ~btn_prev[0];
    assign btn1_rising_edge = btn_sync_1[1] & ~btn_prev[1];
    assign btn2_rising_edge = btn_sync_1[2] & ~btn_prev[2];
    assign btn3_rising_edge = btn_sync_1[3] & ~btn_prev[3];
    wire start_event = btn0_rising_edge | btn1_rising_edge | btn2_rising_edge | btn3_rising_edge;
    // --- End Button Logic ---

    // --- Key/Plaintext Selection Logic ---
    // Load different test vectors based on which button is pressed.
    // These vectors are taken from your test_aes_128.v file.
    always @(posedge sysclk or posedge rst) begin
       if (rst) begin
           plaintext_reg <= 128'h0;
           key_reg <= 128'h0;
       end
       // Test vector 1 from test_aes_128.v
       else if (btn0_rising_edge) begin 
           plaintext_reg <= 128'h3243f6a8885a308d313198a2e0370734;
           key_reg       <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
       end
       // Test vector 2 from test_aes_128.v
       else if (btn1_rising_edge) begin
           plaintext_reg <= 128'hea9f257a796e681121d4cc35d8e7b30;
           key_reg       <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
       end
       // Test vector 3 from test_aes_128.v
       else if (btn2_rising_edge) begin
           plaintext_reg <= 128'h00112233445566778899aabbccddeeff;
           key_reg       <= 128'h000102030405060708090a0b0c0d0e0f;
       end
       // Test vector 4 (example)
       else if (btn3_rising_edge) begin
           plaintext_reg <= 128'hffffffffffffffffffffffffffffffff;
           key_reg       <= 128'h00000000000000000000000000000000;
       end
    end
    
    // --- Trigger and Output Logic ---
    reg [4:0] counter; // 5-bit counter for delay
    localparam IDLE = 0, RUNNING = 1;
    reg state;

    always @(posedge sysclk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            trigger <= 1'b0;
            counter <= 0;
            led <= 4'b0;
            captured_output <= 128'h0;
        end else begin
            case(state)
                IDLE: begin
                    if (start_event) begin
                        trigger <= 1'b1; // Set trigger HIGH
                        state <= RUNNING;
                        counter <= 0;
                    end
                end
                RUNNING: begin
                    // Wait for the AES pipeline to finish
                    // Your aes_128.v has 10 rounds, plus initial XOR.
                    // This pipeline is about 11-12 cycles deep. 
                    // Let's wait 15 cycles to be safe.
                    if (counter == 15) begin
                        trigger <= 1'b0; // Set trigger LOW
                        state <= IDLE;
                        captured_output <= ciphertext_wire; // Latch the result
                        led <= ciphertext_wire[3:0];     // Show result on LEDs
                    end else begin
                        counter <= counter + 1;
                    end
                end
            endcase
        end
    end
    
endmodule