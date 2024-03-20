`timescale 1ns / 1ps
module MultiplierUnit(A, Bi, MULout);
    input [15:0] A;
    input Bi;
    output [15:0] MULout;

    and(MULout[0], A[0], Bi);
    and(MULout[1], A[1], Bi);
    and(MULout[2], A[2], Bi);
    and(MULout[3], A[3], Bi);

    and(MULout[4], A[4], Bi);
    and(MULout[5], A[5], Bi);
    and(MULout[6], A[6], Bi);
    and(MULout[7], A[7], Bi);

    and(MULout[8], A[8], Bi);
    and(MULout[9], A[9], Bi);
    and(MULout[10], A[10], Bi);
    and(MULout[11], A[11], Bi);
    
    and(MULout[12], A[12], Bi);
    and(MULout[13], A[13], Bi);
    and(MULout[14], A[14], Bi);
    and(MULout[15], A[15], Bi);
endmodule

