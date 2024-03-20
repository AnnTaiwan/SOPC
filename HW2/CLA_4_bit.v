`timescale 1ns / 1ps
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