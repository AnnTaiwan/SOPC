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