/*
This module implements the S-Box and other lookup tables
for AES. This is a FIXED version with hardcoded tables
to avoid synthesis errors from $readmemh.
*/
module table_lookup(s0, s1, s2, s3, t0, t1, t2, t3);
    input [31:0] s0, s1, s2, s3;
    output [31:0] t0, t1, t2, t3;
    wire [7:0] a0, a1, a2, a3, b0, b1, b2, b3, c0, c1, c2, c3, d0, d1, d2, d3;

    T t0 (s0[31:24], s1[23:16], s2[15:8],  s3[7:0],   a0, b1, c2, d3);
    T t1 (s1[31:24], s2[23:16], s3[15:8],  s0[7:0],   b0, c1, d2, a3);
    T t2 (s2[31:24], s3[23:16], s0[15:8],  s1[7:0],   c0, d1, a2, b3);
    T t3 (s3[31:24], s0[23:16], s1[15:8],  s2[7:0],   d0, a1, b2, c3);

    assign t0 = {a0, b1, c2, d3};
    assign t1 = {b0, c1, d2, a3};
    assign t2 = {c0, d1, a2, b3};
    assign t3 = {d0, a1, b2, c3};
endmodule

module T(i0, i1, i2, i3, o0, o1, o2, o3);
    input [7:0] i0, i1, i2, i3;
    output [7:0] o0, o1, o2, o3;
    wire [7:0] s0, s1, s2, s3;

    S si0(i0, s0);
    S si1(i1, s1);
    S si2(i2, s2);
    S si3(i3, s3);

    xS m2(s0, o0); // This applies the MixColumn x2 operation
    assign o1 = s1;
    assign o2 = s2;
    assign o3 = s3;
endmodule

// Hardcoded S-Box (replaces file read)
module S(in, out);
    input [7:0] in;
    output [7:0] out;
    reg [7:0] s;
    always @(*)
    case (in)
        8'h00: s = 8'h63; 8'h01: s = 8'h7c; 8'h02: s = 8'h77; 8'h03: s = 8'h7b;
        8'h04: s = 8'hf2; 8'h05: s = 8'h6b; 8'h06: s = 8'h6f; 8'h07: s = 8'hc5;
        8'h08: s = 8'h30; 8'h09: s = 8'h01; 8'h0a: s = 8'h67; 8'h0b: s = 8'h2b;
        8'h0c: s = 8'hfe; 8'h0d: s = 8'hd7; 8'h0e: s = 8'hab; 8'h0f: s = 8'h76;
        8'h10: s = 8'hca; 8'h11: s = 8'h82; 8'h12: s = 8'hc9; 8'h13: s = 8'h7d;
        8'h14: s = 8'hfa; 8'h15: s = 8'h59; 8'h16: s = 8'h47; 8'h17: s = 8'hf0;
        8'h18: s = 8'had; 8'h19: s = 8'hd4; 8'h1a: s = 8'ha2; 8'h1b: s = 8'haf;
        8'h1c: s = 8'h9c; 8'h1d: s = 8'ha4; 8'h1e: s = 8'h72; 8'h1f: s = 8'hc0;
        8'h20: s = 8'hb7; 8'h21: s = 8'hfd; 8'h22: s = 8'h93; 8'h23: s = 8'h26;
        8'h24: s = 8'h36; 8'h25: s = 8'h3f; 8'h26: s = 8'hf7; 8'h27: s = 8'hcc;
        8'h28: s = 8'h34; 8'h29: s = 8'ha5; 8'h2a: s = 8'he5; 8'h2b: s = 8'hf1;
        8'h2c: s = 8'h71; 8'h2d: s = 8'hd8; 8'h2e: s = 8'h31; 8'h2f: s = 8'h15;
        8'h30: s = 8'h04; 8'h31: s = 8'hc7; 8'h32: s = 8'h23; 8'h33: s = 8'hc3;
        8'h34: s = 8'h18; 8'h35: s = 8'h96; 8'h36: s = 8'h05; 8'h37: s = 8'h9a;
        8'h38: s = 8'h07; 8'h39: s = 8'h12; 8'h3a: s = 8'h80; 8'h3b: s = 8'he2;
        8'h3c: s = 8'heb; 8'h3d: s = 8'h27; 8'h3e: s = 8'hb2; 8'h3f: s = 8'h75;
        8'h40: s = 8'h09; 8'h41: s = 8'h83; 8'h42: s = 8'h2c; 8'h43: s = 8'h1a;
        8'h44: s = 8'h1b; 8'h45: s = 8'h6e; 8'h46: s = 8'h5a; 8'h47: s = 8'ha0;
        8'h48: s = 8'h52; 8'h49: s = 8'h3b; 8'h4a: s = 8'hd6; 8'h4b: s = 8'hb3;
        8'h4c: s = 8'h29; 8'h4d: s = 8'he3; 8'h4e: s = 8'h2f; 8'h4f: s = 8'h84;
        8'h50: s = 8'h53; 8'h51: s = 8'hd1; 8'h52: s = 8'h00; 8'h53: s = 8'hed;
        8'h54: s = 8'h20; 8'h55: s = 8'hfc; 8'h56: s = 8'hb1; 8'h57: s = 8'h5b;
        8'h58: s = 8'h6a; 8'h59: s = 8'hcb; 8'h5a: s = 8'hbe; 8'h5b: s = 8'h39;
        8'h5c: s = 8'h4a; 8'h5d: s = 8'h4c; 8'h5e: s = 8'h58; 8'h5f: s = 8'hcf;
        8'h60: s = 8'hd0; 8'h61: s = 8'hef; 8'h62: s = 8'haa; 8'h63: s = 8'hfb;
        8'h64: s = 8'h43; 8'h65: s = 8'h4d; 8'h66: s = 8'h33; 8'h67: s = 8'h85;
        8'h68: s = 8'h45; 8'h69: s = 8'hf9; 8'h6a: s = 8'h02; 8'h6b: s = 8'h7f;
        8'h6c: s = 8'h50; 8'h6d: s = 8'h3c; 8'h6e: s = 8'h9f; 8'h6f: s = 8'ha8;
        8'h70: s = 8'h51; 8'h71: s = 8'ha3; 8'h72: s = 8'h40; 8'h73: s = 8'h8f;
        8'h74: s = 8'h92; 8'h75: s = 8'h9d; 8'h76: s = 8'h38; 8'h77: s = 8'hf5;
        8'h78: s = 8'hbc; 8'h79: s = 8'hb6; 8'h7a: s = 8'hda; 8'h7b: s = 8'h21;
        8'h7c: s = 8'h10; 8'h7d: s = 8'hff; 8'h7e: s = 8'hf3; 8'h7f: s = 8'hd2;
        8'h80: s = 8'hcd; 8'h81: s = 8'h0c; 8'h82: s = 8'h13; 8'h83: s = 8'hec;
        8'h84: s = 8'h5f; 8'h85: s = 8'h97; 8'h86: s = 8'h44; 8'h87: s = 8'h17;
        8'h88: s = 8'hc4; 8'h89: s = 8'ha7; 8'h8a: s = 8'h7e; 8'h8b: s = 8'h3d;
        8'h8c: s = 8'h64; 8'h8d: s = 8'h5d; 8'h8e: s = 8'h19; 8'h8f: s = 8'h73;
        8'h90: s = 8'h60; 8'h91: s = 8'h81; 8'h92: s = 8'h4f; 8'h93: s = 8'hdc;
        8'h94: s = 8'h22; 8'h95: s = 8'h2a; 8'h96: s = 8'h90; 8'h97: s = 8'h88;
        8'h98: s = 8'h46; 8'h99: s = 8'hee; 8'h9a: s = 8'hb8; 8'h9b: s = 8'h14;
        8'h9c: s = 8'hde; 8'h9d: s = 8'h5e; 8'h9e: s = 8'h0b; 8'h9f: s = 8'hdb;
        8'ha0: s = 8'he0; 8'ha1: s = 8'h32; 8'ha2: s = 8'h3a; 8'ha3: s = 8'h0a;
        8'ha4: s = 8'h49; 8'ha5: s = 8'h06; 8'ha6: s = 8'h24; 8'ha7: s = 8'h5c;
        8'ha8: s = 8'hc2; 8'ha9: s = 8'hd3; 8'haa: s = 8'hac; 8'hab: s = 8'h62;
        8'hac: s = 8'h91; 8'had: s = 8'h95; 8'hae: s = 8'he4; 8'haf: s = 8'h79;
        8'hb0: s = 8'he7; 8'hb1: s = 8'hc8; 8'hb2: s = 8'h37; 8'hb3: s = 8'h6d;
        8'hb4: s = 8'h8d; 8'hb5: s = 8'hd5; 8'hb6: s = 8'h4e; 8'hb7: s = 8'ha9;
        8'hb8: s = 8'h6c; 8'hb9: s = 8'h56; 8'hba: s = 8'hf4; 8'hbb: s = 8'hea;
        8'hbc: s = 8'h65; 8'hbd: s = 8'h7a; 8'hbe: s = 8'h8e; 8'hbf: s = 8'h08;
        8'hc0: s = 8'hba; 8'hc1: s = 8'h78; 8'hc2: s = 8'h25; 8'hc3: s = 8'h2e;
        8'hc4: s = 8'h1c; 8'hc5: s = 8'ha6; 8'hc6: s = 8'hb4; 8'hc7: s = 8'hc6;
        8'hc8: s = 8'he8; 8'hc9: s = 8'hdd; 8'hca: s = 8'h74; 8'hcb: s = 8'h1f;
        8'hcc: s = 8'h4b; 8'hcd: s = 8'hbd; 8'hce: s = 8'h8b; 8'hcf: s = 8'h8a;
        8'hd0: s = 8'h70; 8'hd1: s = 8'h3e; 8'hd2: s = 8'hb5; 8'hd3: s = 8'h66;
        8'hd4: s = 8'h48; 8'hd5: s = 8'h03; 8'hd6: s = 8'hf6; 8'hd7: s = 8'h0e;
        8'hd8: s = 8'h61; 8'hd9: s = 8'h35; 8'hda: s = 8'h57; 8'hdb: s = 8'hb9;
        8'hdc: s = 8'h86; 8'hdd: s = 8'hc1; 8'hde: s = 8'h1d; 8'hdf: s = 8'h9e;
        8'he0: s = 8'he1; 8'he1: s = 8'hf8; 8'he2: s = 8'h98; 8'he3: s = 8'h11;
        8'he4: s = 8'h69; 8'he5: s = 8'hd9; 8'he6: s = 8'h8c; 8'he7: s = 8'h94;
        8'he8: s = 8'h9b; 8'he9: s = 8'h1e; 8'hea: s = 8'h87; 8'heb: s = 8'he9;
        8'hec: s = 8'hce; 8'hed: s = 8'h55; 8'hee: s = 8'h28; 8'hef: s = 8'hdf;
        8'hf0: s = 8'h8a; 8'hf1: s = 8'hb1; 8'hf2: s = 8'h89; 8'hf3: s = 8'h0d;
        8'hf4: s = 8'hbf; 8'hf5: s = 8'he6; 8'hf6: s = 8'h42; 8'hf7: s = 8'h68;
        8'hf8: s = 8'h41; 8'hf9: s = 8'h99; 8'hfa: s = 8'h2d; 8'hfb: s = 8'h0f;
        8'hfc: s = 8'hb0; 8'hfd: s = 8'h54; 8'hfe: s = 8'hbb; 8'hff: s = 8'h16;
        default: s = 8'h00;
    endcase
    assign out = s;
endmodule

// Hardcoded xS module (replaces file read)
module xS(in, out);
    input [7:0] in;
    output [7:0] out;
    reg [7:0] s;
    always @(*)
    case (in)
        8'h00: s = 8'h00; 8'h01: s = 8'h02; 8'h02: s = 8'h04; 8'h03: s = 8'h06;
        8'h04: s = 8'h08; 8'h05: s = 8'h0a; 8'h06: s = 8'h0c; 8'h07: s = 8'h0e;
        8'h08: s = 8'h10; 8'h09: s = 8'h12; 8'h0a: s = 8'h14; 8'h0b: s = 8'h16;
        8'h0c: s = 8'h18; 8'h0d: s = 8'h1a; 8'h0e: s = 8'h1c; 8'h0f: s = 8'h1e;
        8'h10: s = 8'h20; 8'h11: s = 8'h22; 8'h12: s = 8'h24; 8'h13: s = 8'h26;
        8'h14: s = 8'h28; 8'h15: s = 8'h2a; 8'h16: s = 8'h2c; 8'h17: s = 8'h2e;
        8'h18: s = 8'h30; 8'h19: s = 8'h32; 8'h1a: s = 8'h34; 8'h1b: s = 8'h36;
        8'h1c: s = 8'h38; 8'h1d: s = 8'h3a; 8'h1e: s = 8'h3c; 8'h1f: s = 8'h3e;
        8'h20: s = 8'h40; 8'h21: s = 8'h42; 8'h22: s = 8'h44; 8'h23: s = 8'h46;
        8'h24: s = 8'h48; 8'h25: s = 8'h4a; 8'h26: s = 8'h4c; 8'h27: s = 8'h4e;
        8'h28: s = 8'h50; 8'h29: s = 8'h52; 8'h2a: s = 8'h54; 8'h2b: s = 8'h56;
        8'h2c: s = 8'h58; 8'h2d: s = 8'h5a; 8'h2e: s = 8'h5c; 8'h2f: s = 8'h5e;
        8'h30: s = 8'h60; 8'h31: s = 8'h62; 8'h32: s = 8'h64; 8'h33: s = 8'h66;
        8'h34: s = 8'h68; 8'h35: s = 8'h6a; 8'h36: s = 8'h6c; 8'h37: s = 8'h6e;
        8'h38: s = 8'h70; 8'h39: s = 8'h72; 8'h3a: s = 8'h74; 8'h3b: s = 8'h76;
        8'h3c: s = 8'h78; 8'h3d: s = 8'h7a; 8'h3e: s = 8'h7c; 8'h3f: s = 8'h7e;
        8'h40: s = 8'h80; 8'h41: s = 8'h82; 8'h42: s = 8'h84; 8'h43: s = 8'h86;
        8'h44: s = 8'h88; 8'h45: s = 8'h8a; 8'h46: s = 8'h8c; 8'h47: s = 8'h8e;
        8'h48: s = 8'h90; 8'h49: s = 8'h92; 8'h4a: s = 8'h94; 8'h4b: s = 8'h96;
        8'h4c: s = 8'h98; 8'h4d: s = 8'h9a; 8'h4e: s = 8'h9c; 8'h4f: s = 8'h9e;
        8'h50: s = 8'ha0; 8'h51: s = 8'ha2; 8'h52: s = 8'ha4; 8'h53: s = 8'ha6;
        8'h54: s = 8'ha8; 8'h55: s = 8'haa; 8'h56: s = 8'hac; 8'h57: s = 8'hae;
        8'h58: s = 8'hb0; 8'h59: s = 8'hb2; 8'h5a: s = 8'hb4; 8'h5b: s = 8'hb6;
        8'h5c: s = 8'hb8; 8'h5d: s = 8'hba; 8'h5e: s = 8'hbc; 8'h5f: s = 8'hbe;
        8'h60: s = 8'hc0; 8'h61: s = 8'hc2; 8'h62: s = 8'hc4; 8'h63: s = 8'hc6;
        8'h64: s = 8'hc8; 8'h65: s = 8'hca; 8'h66: s = 8'hcc; 8'h67: s = 8'hce;
        8'h68: s = 8'hd0; 8'h69: s = 8'hd2; 8'h6a: s = 8'hd4; 8'h6b: s = 8'hd6;
        8'h6c: s = 8'hd8; 8'h6d: s = 8'hda; 8'h6e: s = 8'hdc; 8'h6f: s = 8'hde;
        8'h70: s = 8'he0; 8'h71: s = 8'he2; 8'h72: s = 8'he4; 8'h73: s = 8'he6;
        8'h74: s = 8'he8; 8'h75: s = 8'hea; 8'h76: s = 8'hec; 8'h77: s = 8'hee;
        8'h78: s = 8'hf0; 8'h79: s = 8'hf2; 8'h7a: s = 8'hf4; 8'h7b: s = 8'hf6;
        8'h7c: s = 8'hf8; 8'h7d: s = 8'hfa; 8'h7e: s = 8'hfc; 8'h7f: s = 8'hfe;
        8'h80: s = 8'h1b; 8'h81: s = 8'h19; 8'h82: s = 8'h1f; 8'h83: s = 8'h1d;
        8'h84: s = 8'h13; 8'h85: s = 8'h11; 8'h86: s = 8'h17; 8'h87: s = 8'h15;
        8'h88: s = 8'h0b; 8'h89: s = 8'h09; 8'h8a: s = 8'h0f; 8'h8b: s = 8'h0d;
        8'h8c: s = 8'h03; 8'h8d: s = 8'h01; 8'h8e: s = 8'h07; 8'h8f: s = 8'h05;
        8'h90: s = 8'h3b; 8'h91: s = 8'h39; 8'h92: s = 8'h3f; 8'h93: s = 8'h3d;
        8'h94: s = 8'h33; 8'h95: s = 8'h31; 8'h96: s = 8'h37; 8'h97: s = 8'h35;
        8'h98: s = 8'h2b; 8'h99: s = 8'h29; 8'h9a: s = 8'h2f; 8'h9b: s = 8'h2d;
        8'h9c: s = 8'h23; 8'h9d: s = 8'h21; 8'h9e: s = 8'h27; 8'h9f: s = 8'h25;
        8'ha0: s = 8'h6b; 8'ha1: s = 8'h69; 8'ha2: s = 8'h6f; 8'ha3: s = 8'h6d;
        8'ha4: s = 8'h63; 8'ha5: s = 8'h61; 8'ha6: s = 8'h67; 8'ha7: s = 8'h65;
        8'ha8: s = 8'h7b; 8'ha9: s = 8'h79; 8'haa: s = 8'h7f; 8'hab: s = 8'h7d;
        8'hac: s = 8'h73; 8'had: s = 8'h71; 8'hae: s = 8'h77; 8'haf: s = 8'h75;
        8'hb0: s = 8'h5b; 8'hb1: s = 8'h59; 8'hb2: s = 8'h5f; 8'hb3: s = 8'h5d;
        8'hb4: s = 8'h53; 8'hb5: s = 8'h51; 8'hb6: s = 8'h57; 8'hb7: s = 8'h55;
        8'hb8: s = 8'h4b; 8'hb9: s = 8'h49; 8'hba: s = 8'h4f; 8'hbb: s = 8'h4d;
        8'hbc: s = 8'h43; 8'hbd: s = 8'h41; 8'hbe: s = 8'h47; 8'hbf: s = 8'h45;
        8'hc0: s = 8'hdb; 8'hc1: s = 8'hd9; 8'hc2: s = 8'hdf; 8'hc3: s = 8'hdd;
        8'hc4: s = 8'hd3; 8'hc5: s = 8'hd1; 8'hc6: s = 8'hd7; 8'hc7: s = 8'hd5;
        8'hc8: s = 8'hcb; 8'hc9: s = 8'hc9; 8'hca: s = 8'hcf; 8'hcb: s = 8'hcd;
        8'hcc: s = 8'hc3; 8'hcd: s = 8'hc1; 8'hce: s = 8'hc7; 8'hcf: s = 8'hc5;
        8'hd0: s = 8'hfb; 8'hd1: s = 8'hf9; 8'hd2: s = 8'hff; 8'hd3: s = 8'hfd;
        8'hd4: s = 8'hf3; 8'hd5: s = 8'hf1; 8'hd6: s = 8'hf7; 8'hd7: s = 8'hf5;
        8'hd8: s = 8'heb; 8'hd9: s = 8'he9; 8'hda: s = 8'hef; 8'hdb: s = 8'hed;
        8'hdc: s = 8'he3; 8'hdd: s = 8'he1; 8'hde: s = 8'he7; 8'hdf: s = 8'he5;
        8'he0: s = 8'hab; 8'he1: s = 8'ha9; 8'he2: s = 8'haf; 8'he3: s = 8'had;
        8'he4: s = 8'ha3; 8'he5: s = 8'ha1; 8'he6: s = 8'ha7; 8'he7: s = 8'ha5;
        8'he8: s = 8'hbb; 8'he9: s = 8'hb9; 8'hea: s = 8'hbf; 8'heb: s = 8'hbd;
        8'hec: s = 8'hb3; 8'hed: s = 8'hb1; 8'hee: s = 8'hb7; 8'hef: s = 8'hb5;
        8'hf0: s = 8'h9b; 8'hf1: s = 8'h99; 8'hf2: s = 8'h9f; 8'hf3: s = 8'h9d;
        8'hf4: s = 8'h93; 8'hf5: s = 8'h91; 8'hf6: s = 8'h97; 8'hf7: s = 8'h95;
        8'hf8: s = 8'h8b; 8'hf9: s = 8'h89; 8'hfa: s = 8'h8f; 8'hfb: s = 8'h8d;
        8'hfc: s = 8'h83; 8'hfd: s = 8'h81; 8'hfe: s = 8'h87; 8'hff: s = 8'h85;
        default: s = 8'h00;
    endcase
    assign out = s;
endmodule