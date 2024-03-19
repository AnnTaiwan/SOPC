`timescale 1ns / 1ps
module getPG(input [3:0] A, B, output [3:0] rp, rg);
    xor(rp[0], A[0], B[0]);
    xor(rp[1], A[1], B[1]);
    xor(rp[2], A[2], B[2]);
    xor(rp[3], A[3], B[3]);
//
    and(rg[0], A[0], B[0]);
    and(rg[1], A[1], B[1]);
    and(rg[2], A[2], B[2]);
    and(rg[3], A[3], B[3]);
endmodule

module CLA_4_bit(input [3:0] A, B, input C_in, output C_out, output [3:0] Sum);
    wire [3:0] rp, rg;
    getPG U0(.A(A), .B(B), .rp(rp), .rg(rg));
    wire c1, c2, c3;
    wire n1, n2, n3, n4;
    //carry
    and(n1, rp[0], C_in);
    or(c1, rg[0], n1);
    and(n2, rp[1], c1);
    or(c2, rg[1], n2);
    and(n3, rp[2], c2);
    or(c3, rg[2], n3);
    and(n4, rp[3], c3);
    or(C_out, rg[3], n4);
    //sum
    xor(Sum[0], rp[0], C_in);
    xor(Sum[1], rp[1], c1);
    xor(Sum[2], rp[2], c2);
    xor(Sum[3], rp[3], c3);
endmodule

module CLA_16_bit(input C_in, input [15:0] A, B, output C_out, output [15:0] Sum);
     wire c1, c2, c3; 
     CLA_4_bit CLA_0(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .C_out(c1), .Sum(Sum[3:0]));
     CLA_4_bit CLA_1(.A(A[7:4]), .B(B[7:4]), .C_in(c1), .C_out(c2), .Sum(Sum[7:4]));
     CLA_4_bit CLA_2(.A(A[11:8]), .B(B[11:8]), .C_in(c2), .C_out(c3), .Sum(Sum[11:8]));
     CLA_4_bit CLA_3(.A(A[15:12]), .B(B[15:12]), .C_in(c3), .C_out(C_out), .Sum(Sum[15:12]));
endmodule
