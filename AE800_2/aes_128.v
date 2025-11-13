/*
This module implements the 10-round AES-128 algorithm.
CORRECTED VERSION: s1-s10 and k1-k10 are now wires, not regs.
*/
module aes_128(clk, state, key, out);
    input clk;
    input [127:0] state, key;
    output [127:0] out;
    
    reg [127:0] s0, k0; 
    wire [127:0] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10;
    wire [127:0] k1, k2, k3, k4, k5, k6, k7, k8, k9, k10;
    wire [127:0] k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8b, k9b;

    always @ (posedge clk)
    begin
        s0 <= state ^ key;
        k0 <= key;
    end

    expand_key_128 a1 (.clk(clk), .in(k0),  .out_1(k0b),  .out_2(k1));
    one_round      r1 (.clk(clk), .state_in(s0),  .key_in(k0b),  .state_out(s1));

    expand_key_128 a2 (.clk(clk), .in(k1),  .out_1(k1b),  .out_2(k2));
    one_round      r2 (.clk(clk), .state_in(s1),  .key_in(k1b),  .state_out(s2));

    expand_key_128 a3 (.clk(clk), .in(k2),  .out_1(k2b),  .out_2(k3));
    one_round      r3 (.clk(clk), .state_in(s2),  .key_in(k2b),  .state_out(s3));

    expand_key_128 a4 (.clk(clk), .in(k3),  .out_1(k3b),  .out_2(k4));
    one_round      r4 (.clk(clk), .state_in(s3),  .key_in(k3b),  .state_out(s4));

    expand_key_128 a5 (.clk(clk), .in(k4),  .out_1(k4b),  .out_2(k5));
    one_round      r5 (.clk(clk), .state_in(s4),  .key_in(k4b),  .state_out(s5));

    expand_key_128 a6 (.clk(clk), .in(k5),  .out_1(k5b),  .out_2(k6));
    one_round      r6 (.clk(clk), .state_in(s5),  .key_in(k5b),  .state_out(s6));

    expand_key_128 a7 (.clk(clk), .in(k6),  .out_1(k6b),  .out_2(k7));
    one_round      r7 (.clk(clk), .state_in(s6),  .key_in(k6b),  .state_out(s7));

    expand_key_128 a8 (.clk(clk), .in(k7),  .out_1(k7b),  .out_2(k8));
    one_round      r8 (.clk(clk), .state_in(s7),  .key_in(k7b),  .state_out(s8));

    expand_key_128 a9 (.clk(clk), .in(k8),  .out_1(k8b),  .out_2(k9));
    one_round      r9 (.clk(clk), .state_in(s8),  .key_in(k8b),  .state_out(s9));

    expand_key_128 a10(.clk(clk), .in(k9),  .out_1(k9b),  .out_2(k10));
    final_round    rf (.clk(clk), .state_in(s9),  .key_in(k9b),  .state_out(s10));

    assign out = s10;
endmodule

module expand_key_128(clk, in, out_1, out_2);
    input clk;
    input [127:0] in;
    output [127:0] out_1, out_2;
    reg [31:0] w0, w1, w2, w3, w4, w5, w6, w7;
    wire [31:0] k0;
    wire [7:0] rcon_wire; 

    S4 a1(w3, k0, rcon_wire);
    rcon b1(clk, in[127], rcon_wire); 
    
    always @ (posedge clk)
    begin
        w0 <= in[127:96];
        w1 <= in[95:64];
        w2 <= in[63:32];
        w3 <= in[31:0];

        w4 <= w0 ^ k0;
        w5 <= w1 ^ w4;
        w6 <= w2 ^ w5;
        w7 <= w3 ^ w6;
    end
    assign out_1 = {w0, w1, w2, w3};
    assign out_2 = {w4, w5, w6, w7};
endmodule

module S4(in, out, rcon);
    input [31:0] in;
    output [31:0] out;
    input [7:0] rcon;
    wire [7:0] a0, a1, a2, a3;

    S s1(in[23:16], a0);
    S s2(in[15:8],  a1);
    S s3(in[7:0],   a2);
    S s4(in[31:24], a3);

    assign out = {a0, a1, a2, a3} ^ {rcon, 24'h000000};
endmodule

module rcon(clk, in, out);
    input clk, in;
    output [7:0] out;
    reg [7:0] state;
    
    always @ (posedge clk)
    begin
        if (in)
            state <= 8'h01;
        else if (state == 8'h80)
            state <= 8'h1b;
        else
            state <= state << 1;
    end
    assign out = state;
endmodule