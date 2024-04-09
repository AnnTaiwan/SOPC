`timescale 1ns / 1ps
module CLA_32_bit(
    input C_in,
    input [31:0] A, B,
    output C_out,
    output [31:0] Sum
);

    wire [6:0] c;
    CLA_4_bit CLA_0(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .C_out(c[0]), .Sum(Sum[3:0]));
    CLA_4_bit CLA_1(.A(A[7:4]), .B(B[7:4]), .C_in(c[0]), .C_out(c[1]), .Sum(Sum[7:4]));
    CLA_4_bit CLA_2(.A(A[11:8]), .B(B[11:8]), .C_in(c[1]), .C_out(c[2]), .Sum(Sum[11:8]));
    CLA_4_bit CLA_3(.A(A[15:12]), .B(B[15:12]), .C_in(c[2]), .C_out(c[3]), .Sum(Sum[15:12]));
    CLA_4_bit CLA_4(.A(A[19:16]), .B(B[19:16]), .C_in(c[3]), .C_out(c[4]), .Sum(Sum[19:16]));
    CLA_4_bit CLA_5(.A(A[23:20]), .B(B[23:20]), .C_in(c[4]), .C_out(c[5]), .Sum(Sum[23:20]));
    CLA_4_bit CLA_6(.A(A[27:24]), .B(B[27:24]), .C_in(c[5]), .C_out(c[6]), .Sum(Sum[27:24]));
    CLA_4_bit CLA_7(.A(A[31:28]), .B(B[31:28]), .C_in(c[6]), .C_out(C_out), .Sum(Sum[31:28]));


endmodule
