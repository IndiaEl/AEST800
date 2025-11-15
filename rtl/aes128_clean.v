// AES-128 Encryption Core (Clean - No Trojan)
// This is a simplified AES-128 implementation for educational purposes
// Focuses on demonstrating power, timing, and EM trace generation

module aes128_clean (
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
    
    // Main encryption process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 128'h0;
            ciphertext <= 128'h0;
            done <= 1'b0;
            round <= 4'h0;
            phase <= IDLE;
            round_key <= 128'h0;
        end else begin
            case (phase)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= plaintext;
                        round_key <= key;
                        round <= 4'h0;
                        phase <= INIT;
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
                end
            endcase
        end
    end

endmodule
