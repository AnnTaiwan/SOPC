`timescale 1ns / 1ps
module Mat_Mul_16bits(
    input startR, // Start signal to initiate memory access
    input startC, // Start signal to calculation
    input startW, // Start signal to write memory
    input [31:0] rdata, // Read data output
    input [15:0] sizes, // Size selection for read/write operations
    input clk, // Clock signal
    input rst, // Reset signal
    input rstC,
    input [4:0] size1, size2, size3, // mat_A is size1 * size1, mat_B is size2 * size3.
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
// set the matrix size

parameter MAX_SIZE = 16;
parameter SQU_MAX_SIZE = 256;

// parameter size2 = 4;
// parameter size3 = 4;
integer s1;
integer s2;
integer s3;
integer squ_sizeA, squ_sizeB, total_data_size;
reg [15:0] mat_A [0:SQU_MAX_SIZE-1], mat_B [0:SQU_MAX_SIZE-1]; // two matrix 16*16
reg [15:0] A [0:MAX_SIZE-1], B [0:MAX_SIZE-1];
reg [31:0] mat_Result [0:SQU_MAX_SIZE-1]; //  matrix 4*4
// reg [15:0] i, j, k, temp;
integer i, j, k, temp, h, r; //index
wire [31:0] product[0:MAX_SIZE-1]; // record the  mul result temporarily
//reg C_in;
// reg [31:0] c_a1, c_b1, c_a2, c_b2, c_a3, c_b3;
// wire [31:0] sum1, sum2, sum3;
// wire C_out1, C_out2, C_out3;
// reg [31:0] c_a [0:15]; // one input of the adder
// reg [31:0] c_b [0:15]; // one input of the adder
// wire [31:0] sum [0:15]; // result of the adder
// wire C_out [0:15]; // C-out of the adder
reg [31:0] c_a; // one input of the adder
reg [31:0] c_b; // one input of the adder
wire [31:0] sum; // result of the adder
wire C_out; // C-out of the adder
// reg [9:0] squ_size2;

//assign squ_sizeA = size1 * size2; // used as index  for later
//assign squ_sizeB = size2 * size3; // used as index  for later

initial begin
    // initialize all the array
    for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
        mat_A[h] = 0;
        mat_B[h] = 0;
    end
    for(h = 0; h < MAX_SIZE; h = h + 1) begin
        A[h] = 0;
        B[h] = 0;
       
        // c_a[h] = 0;
        // c_b[h] = 0;
        // sum[h] = 0;
        // C_out[h] = 0;
    end
    for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
        mat_Result[h] = 0;
    end
    
end
always @(posedge clk or posedge rst) begin
    if(rst) begin
        i <= 0; 
        j <= 0; 
        k <= 0;
        temp <= 0;
        h <= 0;
        r <= 0;
        ren <= 0;
        raddr <= 0;
        finishR <= 0;
        finishC <= 0;
        finishW <= 0;
        wdata <= 0;
        waddr <= 0; 
        wen <= 0;
        state_cal <= 0;
        s1 <= size1;
        s2 <= size2;
        s3 <= size3;
        
        squ_sizeA <= size1 * size2; // used as index  for later
        squ_sizeB <= size2 * size3; // used as index  for later
        total_data_size <= size1 * size2 + size2 * size3;
        c_a <= 0;
        c_b <= 0;
              
    end
end

// Read data from external memory at specified read address
// mat_A'datas and mat_B'datas are put into mem seuentially.
// row-major
always @(posedge clk) begin
    if (startR) begin
        ren <= 1;
        if (temp >= 2) begin
            if(i >= 0 && i < squ_sizeA) begin
                mat_A[(i % s2) + (i / s2) * MAX_SIZE] = rdata[15:0];
                $display("rdata: %d", rdata[15:0]);
                $display("raddr: %d", raddr);
                $display("mat_A  (%d): %d", (i % s2) + (i / s2) * MAX_SIZE, mat_A[(i % s2) + (i / s2) * MAX_SIZE]);
            end else if (i >= squ_sizeA && i < total_data_size) begin
                mat_B[((i - squ_sizeA) % s3) + ((i - squ_sizeA) / s3) * MAX_SIZE] = rdata[15:0];
                $display("rdata: %d", rdata[15:0]);
                $display("raddr: %d", raddr);
                $display("mat_B  (%d): %d", ((i - squ_sizeA) % s3) + ((i - squ_sizeA) / s3) * MAX_SIZE, mat_B[((i - squ_sizeA) % s3) + ((i - squ_sizeA) / s3) * MAX_SIZE]);
            end
            if(i >= total_data_size) begin
                //finished read data
                i = 0; // initialize i to 0
                ren <= 0;
                finishR <= 1; // output signal to let the tb know can start doing calculation
            end else begin // go to next clk to save next data
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

//start to multiply mat_A and mat_B, use i to indicate the level of multiplication finishment of mat_rmat_Resultesult
MUL16 m1(.A(A[0]), .B(B[0]), .Product(product[0]));
MUL16 m2(.A(A[1]), .B(B[1]), .Product(product[1]));
MUL16 m3(.A(A[2]), .B(B[2]), .Product(product[2]));
MUL16 m4(.A(A[3]), .B(B[3]), .Product(product[3]));
MUL16 m5(.A(A[4]), .B(B[4]), .Product(product[4]));
MUL16 m6(.A(A[5]), .B(B[5]), .Product(product[5]));
MUL16 m7(.A(A[6]), .B(B[6]), .Product(product[6]));
MUL16 m8(.A(A[7]), .B(B[7]), .Product(product[7]));
MUL16 m9(.A(A[8]), .B(B[8]), .Product(product[8]));
MUL16 m10(.A(A[9]), .B(B[9]), .Product(product[9]));
MUL16 m11(.A(A[10]), .B(B[10]), .Product(product[10]));
MUL16 m12(.A(A[11]), .B(B[11]), .Product(product[11]));
MUL16 m13(.A(A[12]), .B(B[12]), .Product(product[12]));
MUL16 m14(.A(A[13]), .B(B[13]), .Product(product[13]));
MUL16 m15(.A(A[14]), .B(B[14]), .Product(product[14]));
MUL16 m16(.A(A[15]), .B(B[15]), .Product(product[15]));


CLA_32_bit C1(.C_in(1'b0), .A(c_a), .B(c_b), .C_out(C_out), .Sum(sum));
// CLA_32_bit C2(.C_in(C_out[0]), .A(c_a[1]), .B(c_b[1]), .C_out(C_out[1]), .Sum(sum[1]));
// CLA_32_bit C3(.C_in(C_out[1]), .A(c_a[2]), .B(c_b[2]), .C_out(C_out[2]), .Sum(sum[2]));
// CLA_32_bit C4(.C_in(C_out[2]), .A(c_a[3]), .B(c_b[3]), .C_out(C_out[3]), .Sum(sum[3]));
// CLA_32_bit C5(.C_in(C_out[3]), .A(c_a[4]), .B(c_b[4]), .C_out(C_out[4]), .Sum(sum[4]));
// CLA_32_bit C6(.C_in(C_out[4]), .A(c_a[5]), .B(c_b[5]), .C_out(C_out[5]), .Sum(sum[5]));
// CLA_32_bit C7(.C_in(C_out[5]), .A(c_a[6]), .B(c_b[6]), .C_out(C_out[6]), .Sum(sum[6]));
// CLA_32_bit C8(.C_in(C_out[6]), .A(c_a[7]), .B(c_b[7]), .C_out(C_out[7]), .Sum(sum[7]));
// CLA_32_bit C9(.C_in(C_out[7]), .A(c_a[8]), .B(c_b[8]), .C_out(C_out[8]), .Sum(sum[8]));
// CLA_32_bit C10(.C_in(C_out[8]), .A(c_a[9]), .B(c_b[9]), .C_out(C_out[9]), .Sum(sum[9]));
// CLA_32_bit C11(.C_in(C_out[9]), .A(c_a[10]), .B(c_b[10]), .C_out(C_out[10]), .Sum(sum[10]));
// CLA_32_bit C12(.C_in(C_out[10]), .A(c_a[11]), .B(c_b[11]), .C_out(C_out[11]), .Sum(sum[11]));
// CLA_32_bit C13(.C_in(C_out[11]), .A(c_a[12]), .B(c_b[12]), .C_out(C_out[12]), .Sum(sum[12]));
// CLA_32_bit C14(.C_in(C_out[12]), .A(c_a[13]), .B(c_b[13]), .C_out(C_out[13]), .Sum(sum[13]));
// CLA_32_bit C15(.C_in(C_out[13]), .A(c_a[14]), .B(c_b[14]), .C_out(C_out[14]), .Sum(sum[14]));
// CLA_32_bit C16(.C_in(C_out[14]), .A(c_a[15]), .B(c_b[15]), .C_out(C_out[15]), .Sum(sum[15]));

// always @(posedge clk) begin
//     if(rstC) begin
//         i = 0;  // record the current coordinate (i,j) of the result matrix
//         j = 0;  // record the current coordinate (i,j) of the result matrix
//         k = 0; // middle index of  mat_A[i][k] * mat_B[k][j]
//         temp = 0;    
//         state_cal = 0; // mul state -> cal1 -> cal2 -> cal3 // each clk do one state
//     end
// end 


//always @(posedge clk) begin
//    if(startC) begin
//        finishAssign <= 0;
//    end
//end
// start from the result matrix's  first column
always @(posedge clk) begin
        $display("clk at %d", state_cal);
        if(rstC) begin
            i <= 0;  // record the current coordinate (i,j) of the result matrix
            j <= 0;  // record the current coordinate (i,j) of the result matrix
            k <= 0; // middle index of  mat_A[i][k] * mat_B[k][j]   
            r <= 0; // counting index 
            state_cal <= 0; // mul state -> cal1 -> cal2 -> cal3 // each clk do one state
        end
        if(startC) begin
            case(state_cal) 
                0: begin  // product
                    $display("i: %d, j: %d", i, j);
                    // mat_A and mat_B were being reorganized the datas.
                    for(k = 0; k < 16; k = k + 1) begin
                        A[k] = mat_A[i * MAX_SIZE + k];
                        B[k] = mat_B[k * MAX_SIZE + j];
                        $display("A%d : %d, B%d: %d, k: %d, ma: %d, mb: %d",k, A[k], k, B[k], k, mat_A[i * MAX_SIZE + k], mat_B[k * MAX_SIZE + j]);
                    end         
                    // k = k + 1;
                    // if(k >= size2) begin
                    state_cal <= 1;// in next clock, do the sum of product
                    k <= 0; // initiate k to 0 in order to use in next time
                    // end
                end
                1: begin
                    $display("PPP2: %d %d %d %d", product[0], product[1], product[2], product[3]);
                    $display("size2 %d, r inddex at %d", s2, r);
                    $display("SUM: %d", sum);
                    if(s2 == 1) begin
                        state_cal <= 2; // directly go to next state
                        r = 0; // initialize r   for next time
                    end
                    else if(r == 0) begin // s2 >= 2
                        c_a = product[0];
                        c_b = product[1];
                        r = r + 2;
                    end
                    else begin
                        c_a = sum;
                        c_b = product[r];
                        r = r + 1;
                    end

                    if(r >= s2) begin
                        state_cal <= 2; // finished the sum part, so go to next state
                        r = 0; // initialize r   for next time
                    end
                    // get sum[0]
                end
    //             1 : begin // sum
    // //            $display("Result at %d", state_cal);
    //                 c_a[0] = product[0];
    //                 c_b[0] = product[1]; 
    //                 // get sum[0]
    //                 if()
    //                 state_cal <= 2; // go to next state
    //     //            $display("RESULT at %d", state_cal);
    //                 // $display("PPP2: %d %d %d %d", product1, product2, product3, product4);
    //             end
    //             2 : begin
    //                 c_a2 = sum1;
    //                 c_b2 = product3;
    //                 // get sum2
                    
    //                 $display("SUM1: %d %d %d", sum1, sum2, sum3);
    //     //            $display("Result at (%d", state_cal);
    //                 state_cal <= 3; // go to next state
                        
    //             end
    //             3: begin
    //                 c_a3 = sum2;
    //                 c_b3 = product4;
    //                 // get sum3
                    
    //                 $display("SUM2: %d %d %d", sum1, sum2, sum3);
    //     //            $display("Result at (%d", state_cal);
    //                 state_cal <= 4;
                        
    //             end
                2: begin // assign sum to result
                    mat_Result[i * s3 + j] = sum; // final result of mat_Result[i][j]
        //            $display("Result at (%d", state_cal);
                    $display("(%d , %d) MMMAAATTT at %d", i, j , mat_Result[i * s3 + j]);
                    if(j < s3 - 1) begin
                        j = j + 1;
                    end else begin // j==3, go to next row
                        j = 0;
                        i = i + 1;
                    end
                    if(i >= s1) begin // finished the mat_mul
                        state_cal <= 3; // prevent from doing any state in this always blocks
                        finishC <= 1; // finish calculation, output signal
                        // i <= 32; // ready to write sth in memory, addr starts from 32
                        // i <= 0;
                    end else begin
                        state_cal <= 0; // go back to first state to do next result
                    end        
                end
        //         4: begin
        //             $display("SUM3: %d %d %d", sum1, sum2, sum3);
        //             mat_Result[i * size1 + j] = sum3; // final result of mat_Result[i][j]
        // //            $display("Result at (%d", state_cal);
        //             $display("(%d , %d) MMMAAATTT at %d", i, j ,mat_Result[i * size1 + j]);
        //             if(j < 3) begin
        //                 j = j + 1;
        //             end else begin // j==3, go to next row
        //                 j = 0;
        //                 i = i + 1;
        //             end
        //             if(i >= size1) begin // finished the mat_mul
        //                 state_cal <= 5; // prevent from doing any state in this always blocks
        //                 finishC <= 1; // finish calculation, output signal
        //                 i <= 32; // ready to write sth in memory, addr starts from 32
        //                 i <= 0;
        //             end else begin
        //                 state_cal <= 0; // go back to first state to do next result
        //             end                       
        //         end
            endcase
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
