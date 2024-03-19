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

module MUL16(A, B, Product);
    input [15:0] A, B;
    output [31:0] Product; // 32 bits

    wire [15:0] MULout0, MULout1, MULout2, MULout3, 
                MULout4, MULout5, MULout6, MULout7,
                MULout8, MULout9, MULout10, MULout11,
                MULout12, MULout13, MULout14, MULout15;
    wire [15:0] CLA_S0, CLA_S1, CLA_S2, CLA_S3, 
                CLA_S4, CLA_S5, CLA_S6, CLA_S7,
                CLA_S8, CLA_S9, CLA_S10, CLA_S11,
                CLA_S12, CLA_S13, CLA_S14;
    wire    CLA_Cout0, CLA_Cout1, CLA_Cout2, CLA_Cout3, 
            CLA_Cout4, CLA_Cout5, CLA_Cout6, CLA_Cout7,
            CLA_Cout8, CLA_Cout9, CLA_Cout10, CLA_Cout11,
            CLA_Cout12, CLA_Cout13, CLA_Cout14;

    MultiplierUnit M0(.A(A), .Bi(B[0]), .MULout(MULout0));
    MultiplierUnit M1(.A(A), .Bi(B[1]), .MULout(MULout1));
    MultiplierUnit M2(.A(A), .Bi(B[2]), .MULout(MULout2));
    MultiplierUnit M3(.A(A), .Bi(B[3]), .MULout(MULout3));
    MultiplierUnit M4(.A(A), .Bi(B[4]), .MULout(MULout4));
    MultiplierUnit M5(.A(A), .Bi(B[5]), .MULout(MULout5));
    MultiplierUnit M6(.A(A), .Bi(B[6]), .MULout(MULout6));
    MultiplierUnit M7(.A(A), .Bi(B[7]), .MULout(MULout7));
    MultiplierUnit M8(.A(A), .Bi(B[8]), .MULout(MULout8));
    MultiplierUnit M9(.A(A), .Bi(B[9]), .MULout(MULout9));
    MultiplierUnit M10(.A(A), .Bi(B[10]), .MULout(MULout10));
    MultiplierUnit M11(.A(A), .Bi(B[11]), .MULout(MULout11));
    MultiplierUnit M12(.A(A), .Bi(B[12]), .MULout(MULout12));
    MultiplierUnit M13(.A(A), .Bi(B[13]), .MULout(MULout13));
    MultiplierUnit M14(.A(A), .Bi(B[14]), .MULout(MULout14));
    MultiplierUnit M15(.A(A), .Bi(B[15]), .MULout(MULout15));

    // A腳的輸入是把0加在最高位元   
    CLA_16_bit C0(.A({1'b0, MULout0[15:1]}), .B(MULout1), .C_in(1'b0), .C_out(CLA_Cout0), .Sum(CLA_S0));
    CLA_16_bit C1(.A({CLA_Cout0, CLA_S0[15:1]}), .B(MULout2), .C_in(1'b0), .C_out(CLA_Cout1), .Sum(CLA_S1));
    CLA_16_bit C2(.A({CLA_Cout1, CLA_S1[15:1]}), .B(MULout3), .C_in(1'b0), .C_out(CLA_Cout2), .Sum(CLA_S2));
    CLA_16_bit C3(.A({CLA_Cout2, CLA_S2[15:1]}), .B(MULout4), .C_in(1'b0), .C_out(CLA_Cout3), .Sum(CLA_S3));

    CLA_16_bit C4(.A({CLA_Cout3, CLA_S3[15:1]}), .B(MULout5), .C_in(1'b0), .C_out(CLA_Cout4), .Sum(CLA_S4));
    CLA_16_bit C5(.A({CLA_Cout4, CLA_S4[15:1]}), .B(MULout6), .C_in(1'b0), .C_out(CLA_Cout5), .Sum(CLA_S5));
    CLA_16_bit C6(.A({CLA_Cout5, CLA_S5[15:1]}), .B(MULout7), .C_in(1'b0), .C_out(CLA_Cout6), .Sum(CLA_S6));
    CLA_16_bit C7(.A({CLA_Cout6, CLA_S6[15:1]}), .B(MULout8), .C_in(1'b0), .C_out(CLA_Cout7), .Sum(CLA_S7));

    CLA_16_bit C8(.A({CLA_Cout7, CLA_S7[15:1]}), .B(MULout9), .C_in(1'b0), .C_out(CLA_Cout8), .Sum(CLA_S8));
    CLA_16_bit C9(.A({CLA_Cout8, CLA_S8[15:1]}), .B(MULout10), .C_in(1'b0), .C_out(CLA_Cout9), .Sum(CLA_S9));
    CLA_16_bit C10(.A({CLA_Cout9, CLA_S9[15:1]}), .B(MULout11), .C_in(1'b0), .C_out(CLA_Cout10), .Sum(CLA_S10));
    CLA_16_bit C11(.A({CLA_Cout10, CLA_S10[15:1]}), .B(MULout12), .C_in(1'b0), .C_out(CLA_Cout11), .Sum(CLA_S11));

    CLA_16_bit C12(.A({CLA_Cout11, CLA_S11[15:1]}), .B(MULout13), .C_in(1'b0), .C_out(CLA_Cout12), .Sum(CLA_S12));
    CLA_16_bit C13(.A({CLA_Cout12, CLA_S12[15:1]}), .B(MULout14), .C_in(1'b0), .C_out(CLA_Cout13), .Sum(CLA_S13));
    CLA_16_bit C14(.A({CLA_Cout13, CLA_S13[15:1]}), .B(MULout15), .C_in(1'b0), .C_out(CLA_Cout14), .Sum(CLA_S14));

    assign Product[0] = MULout0[0];
    assign Product[1]  = CLA_S0[0];
    assign Product[2]  = CLA_S1[0];
    assign Product[3]  = CLA_S2[0];
    assign Product[4]  = CLA_S3[0];
    assign Product[5]  = CLA_S4[0];
    assign Product[6]  = CLA_S5[0];
    assign Product[7]  = CLA_S6[0];
    assign Product[8]  = CLA_S7[0];
    assign Product[9]  = CLA_S8[0];
    assign Product[10] = CLA_S9[0];
    assign Product[11] = CLA_S10[0];
    assign Product[12] = CLA_S11[0];
    assign Product[13] = CLA_S12[0];
    assign Product[14] = CLA_S13[0];

    assign Product[30:15] = CLA_S14;
    assign Product[31] = CLA_Cout14;
    
endmodule