// AES-128 Encryption Core with AEST800 Trojan
// This implementation contains a hardware trojan that:
// 1. Leaks key bits through power side-channel
// 2. Creates timing variations based on key values
// 3. Generates detectable EM signatures
//
// AEST800 Trojan Description:
// - Activates on specific plaintext patterns
// - Introduces additional switching activity proportional to key bits
// - Creates subtle timing delays that correlate with secret key

module aes128_trojan (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [127:0] plaintext,
    input wire [127:0] key,
    output reg [127:0] ciphertext,
    output reg done
);

    // State registers
    reg [127:0] state;
    reg [3:0] round;
    reg [1:0] phase;
    
    // Round key registers
    reg [127:0] round_key;
    
    // TROJAN COMPONENTS
    reg [7:0] trojan_counter;
    reg trojan_active;
    wire trojan_trigger;
    reg [31:0] power_leakage_reg;  // Extra register for power leakage
    reg [15:0] timing_delay_reg;   // Register to create timing variations
    
    // Trojan trigger: activates on specific plaintext patterns
    // Trigger condition: when lower 16 bits match specific pattern
    assign trojan_trigger = (plaintext[15:0] == 16'hABCD) || (plaintext[31:16] == 16'h1234);
    
    // Parameters
    parameter IDLE = 2'b00;
    parameter INIT = 2'b01;
    parameter ROUND = 2'b10;
    parameter FINAL = 2'b11;
    
    // S-box lookup (simplified - using a subset for demonstration)
    function [7:0] sbox;
        input [7:0] in;
        begin
            case(in[3:0])
                4'h0: sbox = 8'h63;
                4'h1: sbox = 8'h7c;
                4'h2: sbox = 8'h77;
                4'h3: sbox = 8'h7b;
                4'h4: sbox = 8'hf2;
                4'h5: sbox = 8'h6b;
                4'h6: sbox = 8'h6f;
                4'h7: sbox = 8'hc5;
                4'h8: sbox = 8'h30;
                4'h9: sbox = 8'h01;
                4'ha: sbox = 8'h67;
                4'hb: sbox = 8'h2b;
                4'hc: sbox = 8'hfe;
                4'hd: sbox = 8'hd7;
                4'he: sbox = 8'hab;
                4'hf: sbox = 8'h76;
            endcase
        end
    endfunction
    
    // SubBytes operation
    function [127:0] sub_bytes;
        input [127:0] data;
        integer i;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                sub_bytes[i*8 +: 8] = sbox(data[i*8 +: 8]);
            end
        end
    endfunction
    
    // ShiftRows operation (simplified)
    function [127:0] shift_rows;
        input [127:0] data;
        begin
            shift_rows = {
                data[127:120], data[87:80], data[47:40], data[7:0],
                data[95:88], data[55:48], data[15:8], data[103:96],
                data[63:56], data[23:16], data[111:104], data[71:64],
                data[31:24], data[119:112], data[79:72], data[39:32]
            };
        end
    endfunction
    
    // MixColumns operation (simplified - XOR based)
    function [127:0] mix_columns;
        input [127:0] data;
        integer i;
        begin
            for (i = 0; i < 4; i = i + 1) begin
                mix_columns[i*32 +: 32] = data[i*32 +: 32] ^ {data[i*32+24 +: 8], data[i*32 +: 24]};
            end
        end
    endfunction
    
    // AddRoundKey
    function [127:0] add_round_key;
        input [127:0] data;
        input [127:0] rkey;
        begin
            add_round_key = data ^ rkey;
        end
    endfunction
    
    // Simple key schedule (simplified for demonstration)
    function [127:0] next_round_key;
        input [127:0] key;
        input [3:0] rnd;
        begin
            next_round_key = {key[95:0], key[127:96]} ^ {rnd, rnd, rnd, rnd, rnd, rnd, rnd, rnd, 
                                                          rnd, rnd, rnd, rnd, rnd, rnd, rnd, rnd,
                                                          rnd, rnd, rnd, rnd, rnd, rnd, rnd, rnd,
                                                          rnd, rnd, rnd, rnd, rnd, rnd, rnd, rnd};
        end
    endfunction
    
    // TROJAN LOGIC: Power leakage mechanism
    // Creates additional switching activity based on key bits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            power_leakage_reg <= 32'h0;
            trojan_counter <= 8'h0;
        end else if (trojan_active && phase == ROUND) begin
            // Leak key bits through extra switching activity
            // When key bit is 1, toggle more frequently
            power_leakage_reg <= power_leakage_reg ^ {round_key[31:0]};
            trojan_counter <= trojan_counter + (|round_key[7:0]);
        end
    end
    
    // TROJAN LOGIC: Timing delay mechanism
    // Creates timing variations correlated with key bits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timing_delay_reg <= 16'h0;
        end else if (trojan_active && phase == ROUND) begin
            // Add delay cycles proportional to number of 1's in key segment
            timing_delay_reg <= timing_delay_reg + {8'h0, 
                round_key[127] + round_key[126] + round_key[125] + round_key[124] +
                round_key[123] + round_key[122] + round_key[121] + round_key[120]};
        end
    end
    
    // Main encryption process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 128'h0;
            ciphertext <= 128'h0;
            done <= 1'b0;
            round <= 4'h0;
            phase <= IDLE;
            round_key <= 128'h0;
            trojan_active <= 1'b0;
        end else begin
            case (phase)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= plaintext;
                        round_key <= key;
                        round <= 4'h0;
                        phase <= INIT;
                        // TROJAN: Activate on trigger
                        trojan_active <= trojan_trigger;
                    end
                end
                
                INIT: begin
                    // Initial AddRoundKey
                    state <= add_round_key(state, round_key);
                    round <= 4'h1;
                    round_key <= next_round_key(round_key, 4'h0);
                    phase <= ROUND;
                end
                
                ROUND: begin
                    if (round <= 4'd9) begin
                        // Apply transformations
                        state <= sub_bytes(state);
                        state <= shift_rows(state);
                        if (round < 4'd10)
                            state <= mix_columns(state);
                        state <= add_round_key(state, round_key);
                        round_key <= next_round_key(round_key, round);
                        
                        // TROJAN: Inject timing delay based on timing_delay_reg
                        if (trojan_active && timing_delay_reg[0])
                            round <= round; // Stall for one cycle
                        else
                            round <= round + 1;
                    end else begin
                        phase <= FINAL;
                    end
                end
                
                FINAL: begin
                    // Output final ciphertext
                    ciphertext <= state;
                    done <= 1'b1;
                    phase <= IDLE;
                    trojan_active <= 1'b0;
                end
            endcase
        end
    end

endmodule
