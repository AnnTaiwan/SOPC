`timescale 1ns / 1ps
module Mat_mul_16bits_4x4_4x4(
    input startR, // Start signal to initiate memory access
    input startC, // Start signal to calculation
    input startW, // Start signal to write memory
    input [31:0] rdata, // Read data output
    input [15:0] sizes, // Size selection for read/write operations
    input clk, // Clock signal
    input rst, // Reset signal
    input rstC,
    output reg [2:0] state_cal, // finished assigning the number into register, and then do the sum of product
    output reg [15:0] raddr, // Read address input
    output reg ren, // Read enable signal
    output reg finishR, // Finish signal to indicate completion of memory access
    output reg finishC, // Finish signal to indicate completion of calculation
    output reg finishW, // Finish signal to indicate completion of write
    output reg [31:0] wdata, // Write data input
    output reg [15:0] waddr, // Write address input
    output reg wen // Write enable signal
);

reg [15:0] mat_A [0:15], mat_B [0:15]; // two matrix 4*4
reg [15:0] A1, B1, A2, B2, A3, B3, A4, B4;
reg [31:0] mat_Result [0:15]; //  matrix 4*4
reg [15:0] i, j, k, temp;
wire [31:0] product1, product2, product3, product4; // record the  mul result temporarily
//reg [2:0] state_cal; // finished assigning the number into register, and then do the sum of product

//reg [15:0] rdata_reg; // 用于存??取到的?据的寄存器
//Read data
initial begin 
    i = 0; 
    j = 0; 
    k = 0;
    temp = 0;
    ren = 0;
    raddr = 0;
    finishR = 0;
    finishC = 0;
    finishW = 0;
    wdata = 0;
    waddr = 0; 
    wen = 0;
    
//    mat_A[0] = 0;
//    mat_A[1] = 1;
//    mat_A[2] = 2;
//    mat_A[3] = 3;
//    mat_A[4] = 4;
//    mat_A[5] = 5;
//    mat_A[6] = 6;
//    mat_A[7] = 7;
//    mat_A[8] = 8;
//    mat_A[9] = 9;
//    mat_A[10] = 10;
//    mat_A[11] = 11;
//    mat_A[12] = 12;
//    mat_A[13] = 13;
//    mat_A[14] = 14;
//    mat_A[15] = 15;
//    mat_B[0] = 16;
//    mat_B[1] = 17;
//    mat_B[2] = 18;
//    mat_B[3] = 19;
//    mat_B[4] = 20;
//    mat_B[5] = 21;
//    mat_B[6] = 22;
//    mat_B[7] = 23;
//    mat_B[8] = 24;
//    mat_B[9] = 25;
//    mat_B[10] = 26;
//    mat_B[11] = 27;
//    mat_B[12] = 28;
//    mat_B[13] = 29;
//    mat_B[14] = 30;
//    mat_B[15] = 31;

end



// Read data to external memory at specified read address
//Memory R1(.waddr(waddr), .wdata(wdata), .wen(wen), .sizes(sizes), .raddr(raddr), .ren(ren), .rdata(rdata), .clk(clk), .rst(rst));
always @(posedge clk) begin
    if (startR) begin
        ren <= 1;
        if (temp >= 2) begin
            if(i >= 0 && i < 16) begin
                mat_A[i] = rdata[15:0];
                $display("rdata: %d", rdata[15:0]);
                $display("raddr: %d", raddr);
                $display("mat_A  (%d): %d", i, mat_A[i]);
            end else if (i >= 16 && i < 32) begin
                mat_B[i - 16] = rdata[15:0];
                $display("rdata: %d", rdata[15:0]);
                $display("raddr: %d", raddr);
                $display("mat_B  (%d): %d", i, mat_B[i-16]);
            end
            if(i >= 32) begin
                //finished read data
                i = 0; // initialize i to 0
                ren <= 0;
                finishR <= 1; // output signal to let the tb know can start doing calculation
            end else begin
                i = i + 1;
                raddr <= raddr + 1;
    //            rdata_reg <= rdata[15:0];
            end
            if(temp == 2) begin
                i = i - 1;
                temp = temp + 1;
            end
        end else begin
            temp = temp + 1;
            
                
        end
    end
end
//reg C_in;
reg [31:0] c_a1, c_b1, c_a2, c_b2, c_a3, c_b3;
wire [31:0] sum1, sum2, sum3;
wire C_out1, C_out2, C_out3;
//start to multiply mat_A and mat_B, use i to indicate the level of multiplication finishment of mat_rmat_Resultesult
MUL16 m1(.A(A1), .B(B1), .Product(product1));
MUL16 m2(.A(A2), .B(B2), .Product(product2));
MUL16 m3(.A(A3), .B(B3), .Product(product3));
MUL16 m4(.A(A4), .B(B4), .Product(product4));

CLA_32_bit C1(.C_in(1'b0), .A(c_a1), .B(c_b1), .C_out(C_out1), .Sum(sum1));
CLA_32_bit C2(.C_in(1'b0), .A(c_a2), .B(c_b2), .C_out(C_out2), .Sum(sum2));
CLA_32_bit C3(.C_in(1'b0), .A(c_a3), .B(c_b3), .C_out(C_out3), .Sum(sum3));

always @(posedge clk) begin
    if(rstC) begin
        i = 0;  // record the current coordinate (i,j) of the result matrix
        j = 0;  // record the current coordinate (i,j) of the result matrix
        k = 0; // middle index of  mat_A[i][k] * mat_B[k][j]
        temp = 0;    
        state_cal = 0; // mul state -> cal1 -> cal2 -> cal3 // each clk do one state
    end
end


//always @(posedge clk) begin
//    if(startC) begin
//        finishAssign <= 0;
//    end
//end
// start from the result matrix's  first column
always @(posedge clk) begin
        $display("clk at %d", state_cal);
        if(startC && state_cal == 0) begin
            $display("i: %d, j: %d", i, j);
//            $display("Result at %d", state_cal);
            A1 = mat_A[i * 4 + k]; 
            B1 = mat_B[k * 4 + j]; 
//            $display("A1 : %d, B1: %d, k: %d, ma: %d, mb: %d",A1, B1, k, mat_A[i * 4 + k], mat_B[k * 4 + j]);
            k = k + 1; 
            A2 = mat_A[i * 4 + k];
            B2 = mat_B[k * 4 + j];
//            $display("A2 : %d, B2: %d, k: %d, ma: %d, mb: %d", A2, B2, k, mat_A[i * 4 + k], mat_B[k * 4 + j]);
            k = k + 1;
            A3 = mat_A[i * 4 + k];
            B3 = mat_B[k * 4 + j];
//            $display("A2 : %d, B2: %d, k: %d, ma: %d, mb: %d", A3, B3, k, mat_A[i * 4 + k], mat_B[k * 4 + j]);
            k = k + 1;
            A4 = mat_A[i * 4 + k];
            B4 = mat_B[k * 4 + j];
//            $display("A2 : %d, B2: %d, k: %d, ma: %d, mb: %d", A4, B4, k, mat_A[i * 4 + k], mat_B[k * 4 + j]);
            k = k + 1;
            if(k >= 4) begin
                state_cal <= 1;// in next clock, do the sum of product
                k = 0; // initiate k to 0 in order to use in next time
            end
        end
        else if(startC && state_cal == 1) begin
//            $display("Result at %d", state_cal);
            c_a1 = product1;
            c_b1 = product2; 
            // get sum1
        
            state_cal <= 2; // go to next state
//            $display("RESULT at %d", state_cal);
            $display("PPP2: %d %d %d %d", product1, product2, product3, product4);
       end
       else if(startC && state_cal == 2) begin
            c_a2 = sum1;
            c_b2 = product3;
            // get sum2
            
            $display("SUM1: %d %d %d", sum1, sum2, sum3);
//            $display("Result at (%d", state_cal);
            state_cal <= 3; // go to next state
                
        end
        else if(startC && state_cal == 3) begin
            c_a3 = sum2;
            c_b3 = product4;
            // get sum3
            
            $display("SUM2: %d %d %d", sum1, sum2, sum3);
//            $display("Result at (%d", state_cal);
            state_cal <= 4;
                
        end
        else if(startC && state_cal == 4) begin
            $display("SUM3: %d %d %d", sum1, sum2, sum3);
            mat_Result[i * 4 + j] = sum3; // final result of mat_Result[i][j]
//            $display("Result at (%d", state_cal);
            $display("(%d , %d) MMMAAATTT at %d", i, j ,mat_Result[i * 4 + j]);
            if(j < 3) begin
                j = j + 1;
            end else begin // j==3, go to next row
                j = 0;
                i = i + 1;
            end
            if(i >= 4) begin // finished the mat_mul
                state_cal <= 5; // prevent from doing any state in this always blocks
                finishC <= 1; // finish calculation, output signal
                i <= 32; // ready to write sth in memory, addr starts from 32
                i <= 0;
            end else begin
                state_cal <= 0; // go back to first state to do next result
            end
                
        end
end
//always @(posedge clk) begin
//    if(startC && state_cal == 1) begin          
//            $display("Result at %d", state_cal);
            
//            c_a1 = product1;
//            c_b1 = product2;
//            c_a2 = sum1;
//            c_b2 = product3;
//            c_a3 = sum2;
//            c_b3 = product4;
//            $display("PPP: %d %d %d %d", product1, product2, product3, product4);
////            mat_Result[i * 4 + j] = sum3;
////            $display("Result at (%d, %d): %d", i, j, mat_Result[i*4+j]);
////            i = 4;
////            if(i >= 4) begin
//                state_cal <= 2;
//                $display("Result at %d", state_cal);
//                $display("PPP2: %d %d %d %d", product1, product2, product3, product4);
////            end
//       end
//end
//always @(posedge clk) begin
//    if(startC && state_cal == 2) begin
//            $display("SUM: %d %d %d", sum1, sum2, sum3);
//            mat_Result[i * 4 + j] = sum3;
//            $display("Result at (%d", state_cal);
////            i = 4;
////            if(i >= 4) begin
//                state_cal = 4;
//                finishC <= 1;
//                i = 32;
//                i <= 0;
////            end
//       end
//end
//always @(*) begin
//    if (startC) begin
//        for (i = 0; i < 4; i = i + 1) begin
//            for (j = 0; j < 4; j = j + 1) begin
//                mat_Result[i*4+j] = 0;        
//                for (k = 0; k < 4; k = k + 1) begin
//                    A1 = mat_A[i*4+k];
//                    B1 = mat_B[k*4+j];
//                    c_a1 = mat_Result[i*4+j];
//                    c_b1 = product1;
//                    mat_Result[i*4+j] = sum1;     
////                    $display("(%h, %h): %h", A, B, product);  
//                end
////                $display("Result at (%d, %d): %d", i, j, mat_Result[i*4+j]);
//            end
//        end
  
//        //  finished calculation
//        i <= 32; // ready to write data
//        finishC <= 1; // output signal
//    end
//end

// Write data to external memory at specified write address
//Memory W1(.waddr(waddr), .wdata(wdata), .wen(wen), .sizes(sizes), .raddr(raddr), .ren(ren), .rdata(rdata), .clk(clk), .rst(rst));
always @(posedge clk) begin
    if (startW) begin
        wen <= 1;
        if(i - 32 < 16) begin
            wdata <= mat_Result[i - 32];
            waddr <= i;
        end
        if (i - 32  >= 16) begin
            i <= 0;
            finishW <= 1;
        end else begin
            i <= i + 1;
        end
    end
end

endmodule
