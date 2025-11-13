// NOTE: `include "table.v" line has been REMOVED.

module one_round(clk, state_in, key_in, state_out);
    input clk;
    input [127:0] state_in, key_in;
    output [127:0] state_out;
    reg [31:0] s0, s1, s2, s3, k0, k1, k2, k3;
    wire [31:0] t0, t1, t2, t3;
    
    always @ (posedge clk)
    begin
        s0 <= state_in[127:96];
        s1 <= state_in[95:64];
        s2 <= state_in[63:32];
        s3 <= state_in[31:0];
        k0 <= key_in[127:96];
        k1 <= key_in[95:64];
        k2 <= key_in[63:32];
        k3 <= key_in[31:0];
    end

    table_lookup t0(s0, s1, s2, s3, t0, t1, t2, t3);
    assign state_out = {t0^k0, t1^k1, t2^k2, t3^k3};
endmodule

module final_round(clk, state_in, key_in, state_out);
    input clk;
    input [127:0] state_in, key_in;
    output [127:0] state_out;
    reg [31:0] s0, s1, s2, s3, k0, k1, k2, k3;
    reg [31:0] t0, t1, t2, t3;
    wire [7:0] a0, a1, a2, a3, b0, b1, b2, b3, c0, c1, c2, c3, d0, d1, d2, d3;

    S s00(s0[31:24], a0);
    S s01(s1[23:16], b1);
    S s02(s2[15:8],  c2);
    S s03(s3[7:0],   d3);
    S s10(s1[31:24], b0);
    S s11(s2[23:16], c1);
    S s12(s3[15:8],  d2);
    S s13(s0[7:0],   a3);
    S s20(s2[31:24], c0);
    S s21(s3[23:16], d1);
    S s22(s0[15:8],  a2);
    S s23(s1[7:0],   b3);
    S s30(s3[31:24], d0);
    S s31(s0[23:16], a1);
    S s32(s1[15:8],  b2);
    S s33(s2[7:0],   c3);

    always @ (posedge clk)
    begin
        s0 <= state_in[127:96];
        s1 <= state_in[95:64];
        s2 <= state_in[63:32];
        s3 <= state_in[31:0];
        k0 <= key_in[127:96];
        k1 <= key_in[95:64];
        k2 <= key_in[63:32];
        k3 <= key_in[31:0];
        
        t0 <= {a0, b1, c2, d3};
        t1 <= {b0, c1, d2, a3};
        t2 <= {c0, d1, a2, b3};
        t3 <= {d0, a1, b2, c3};
    end
    
    assign state_out = {t0^k0, t1^k1, t2^k2, t3^k3};
endmodule