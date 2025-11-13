`timescale 1ns / 1ps
 
/*
This is the corrected TOP-LEVEL module.
It adds a 'trigger' output port and the logic to pulse it
when an AES operation starts.
*/
 
module aes_harness_top(
    input wire sysclk, // Main system clock
    input wire rst,    // Reset
    input wire [3:0] btn, // 4 buttons
    output reg [3:0] led, // 4 LEDs
    output reg trigger    // <-- NEW TRIGGER OUTPUT PORT
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
    // Loads test vectors based on button presses
    always @(posedge sysclk or posedge rst) begin
       if (rst) begin
           plaintext_reg <= 128'h0;
           key_reg <= 128'h0;
       end
       else if (btn0_rising_edge) begin // Test vector 1
           plaintext_reg <= 128'h3243f6a8885a308d313198a2e0370734;
           key_reg       <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
       end
       else if (btn1_rising_edge) begin // Test vector 2
           plaintext_reg <= 128'hea9f257a796e681121d4cc35d8e7b30;
           key_reg       <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
       end
       else if (btn2_rising_edge) begin // Test vector 3
           plaintext_reg <= 128'h00112233445566778899aabbccddeeff;
           key_reg       <= 128'h000102030405060708090a0b0c0d0e0f;
       end
       else if (btn3_rising_edge) begin // Example test vector
           plaintext_reg <= 128'hffffffffffffffffffffffffffffffff;
           key_reg       <= 128'h00000000000000000000000000000000;
       end
    end
    // --- START: NEW TRIGGER AND OUTPUT LOGIC ---
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
                        trigger <= 1'b1; // SET TRIGGER HIGH
                        state <= RUNNING;
                        counter <= 0;
                    end
                end
                RUNNING: begin
                    // Wait for the AES pipeline to finish (approx. 15 cycles)
                    if (counter == 15) begin
                        trigger <= 1'b0; // SET TRIGGER LOW
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
    // --- END: NEW TRIGGER AND OUTPUT LOGIC ---
endmodule