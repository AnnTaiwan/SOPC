`timescale 1ns / 1ps
module CLA_16_bit(input C_in, input [15:0] A, B, output C_out, output [15:0] Sum);
     wire c1, c2, c3; 
     CLA_4_bit CLA_0(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .C_out(c1), .Sum(Sum[3:0]));
     CLA_4_bit CLA_1(.A(A[7:4]), .B(B[7:4]), .C_in(c1), .C_out(c2), .Sum(Sum[7:4]));
     CLA_4_bit CLA_2(.A(A[11:8]), .B(B[11:8]), .C_in(c2), .C_out(c3), .Sum(Sum[11:8]));
     CLA_4_bit CLA_3(.A(A[15:12]), .B(B[15:12]), .C_in(c3), .C_out(C_out), .Sum(Sum[15:12]));
endmodule
