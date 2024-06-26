`timescale 1ns / 1ps
module Mat_Mul_16bits(
    input startR, // Start signal to initiate memory access
    input startC, // Start signal to calculate
    input startW, // Start signal to write memory
    input [31:0] rdata, // Read data output from input memory
    input [15:0] sizes, // Size selection for read/write operations
    input wire clk, // Clock signal
    input rst, // Reset signal
    input rstC, // reset for the calculation
    input [4:0] size1, size2, size3, // mat_A is size1 * size1, mat_B is size2 * size3.
    output reg [2:0] state_cal, // contrl the state of the matrix multiplication process
    output reg [15:0] raddr, // Read address input to input memory
    output reg ren, // Read enable signal to input memory 
    output reg finishR, // Finish signal to indicate completion of memory access
    output reg finishC, // Finish signal to indicate completion of calculation
    output reg finishW, // Finish signal to indicate completion of write
    output reg [31:0] wdata, // Write data input to output memory
    output reg [15:0] waddr, // Write address input to output memory
    output reg wen // Write enable signal to output memory
);
// set the max matrix size 16x16
parameter MAX_SIZE = 16;
parameter SQU_MAX_SIZE = 256;
// each size should be <= 16.
integer s1; // szie1
integer s2; // size2
integer s3; // size3
integer squ_sizeA, squ_sizeB, total_data_size; 
// declare arrray
reg [15:0] mat_A [0:SQU_MAX_SIZE-1], mat_B [0:SQU_MAX_SIZE-1]; // two source matrix 
reg [15:0] A [0:MAX_SIZE-1], B [0:MAX_SIZE-1]; // input of mul_unit(16)
reg [31:0] mat_Result [0:SQU_MAX_SIZE-1]; //  result matrix 

integer i, j, i2, j2, i3, j3, k, temp, temp2, h, r, p; //index
wire [31:0] product[0:MAX_SIZE-1]; // record the mul_unit result

//C_in is always 1'b0
reg [31:0] c_a[0:7]; // one input of the adder
reg [31:0] c_b[0:7]; // one input of the adder
wire [31:0] sum[0:7]; // result of the adder
wire C_out[0:7]; // C-out of the adder

always @(posedge clk or posedge rst) begin
    // initialize
    if(rst) begin      
//        ren <= 0;
//        raddr <= 0;
//        finishR <= 0;
//        finishC <= 0;
//        finishW <= 0;
////        wdata <= 0;
////        waddr <= 0; 
//        wen <= 0;
//        state_cal <= 0;
        s1 <= size1;
        s2 <= size2;
        s3 <= size3;
        
        squ_sizeA <= size1 * size2; // used as index  for later
        squ_sizeB <= size2 * size3; // used as index  for later
        total_data_size <= size1 * size2 + size2 * size3; // used as index  for later
        
//        // initialize all the array
//        for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
//            mat_A[h] <= 0;
//            mat_B[h] <= 0;
//            mat_Result[h] <= 0;
//        end
//        for(p = 0; p < MAX_SIZE; p = p + 1) begin
//            A[p] <= 0;
//            B[p] <= 0;
//        end
    end
end

// Read data from external memory at specified read address
// mat_A'datas and mat_B'datas are put into mem seuentially.
// in order to use the mul_unit later, I assign the matrix data into 2D way, not linearly
// row-major
always @(posedge clk) begin
    if(rst) begin
        raddr <= 0;
        finishR <= 0;
        ren <= 0;
        i <= 0; 
        j <= 0; 
        temp <= 0;
        // initialize all the array
        for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
            mat_A[h] <= 0;
            mat_B[h] <= 0;
        end
    end
    else if (startR) begin
        ren <= 1;
        if (temp >= 2) begin // temp used for fixing the delay problem between this module and Memory module
            if(i >= 0 && i < squ_sizeA) begin
                mat_A[(i % s2) + (i / s2) * MAX_SIZE] <= rdata[15:0]; // assign the data into 2D way, not linearly
            end else if (i >= squ_sizeA && i < total_data_size) begin
                mat_B[((i - squ_sizeA) % s3) + ((i - squ_sizeA) / s3) * MAX_SIZE] <= rdata[15:0]; // assign the data into 2D way, not linearly
            end
            if(i >= total_data_size) begin
                //finished reading data
                ren <= 0;
                finishR <= 1; // output signal to let the tb know can start doing calculation
            end else begin // go to next clk to save next data
                i <= i + 1;
                raddr <= raddr + 1;
            end
            if(temp <= 2) begin
                i <= 0;
                temp <= temp + 1;
            end
        end else begin
            temp <= temp + 1;                           
        end
    end
end

// 16 16-bit multiplier units
//start to multiply mat_A and mat_B, use i to indicate the level of multiplication finishment of mat_Result
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
// 1 32-bit adder
CLA_32_bit C1(.C_in(1'b0), .A(c_a[0]), .B(c_b[0]), .C_out(C_out[0]), .Sum(sum[0]));
CLA_32_bit C2(.C_in(1'b0), .A(c_a[1]), .B(c_b[1]), .C_out(C_out[1]), .Sum(sum[1]));
CLA_32_bit C3(.C_in(1'b0), .A(c_a[2]), .B(c_b[2]), .C_out(C_out[2]), .Sum(sum[2]));
CLA_32_bit C4(.C_in(1'b0), .A(c_a[3]), .B(c_b[3]), .C_out(C_out[3]), .Sum(sum[3]));
CLA_32_bit C5(.C_in(1'b0), .A(c_a[4]), .B(c_b[4]), .C_out(C_out[4]), .Sum(sum[4]));
CLA_32_bit C6(.C_in(1'b0), .A(c_a[5]), .B(c_b[5]), .C_out(C_out[5]), .Sum(sum[5]));
CLA_32_bit C7(.C_in(1'b0), .A(c_a[6]), .B(c_b[6]), .C_out(C_out[6]), .Sum(sum[6]));
CLA_32_bit C8(.C_in(1'b0), .A(c_a[7]), .B(c_b[7]), .C_out(C_out[7]), .Sum(sum[7]));

// start from the result matrix's  first column
always @(posedge clk) begin
        // $display("clk at %d", state_cal);
        if(rst) begin
            finishC <= 0;
            state_cal <= 0;
            // initialize all the array
            for(p = 0; p < MAX_SIZE; p = p + 1) begin
                A[p] <= 0;
                B[p] <= 0;
            end
            for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
                mat_Result[h] <= 0;
            end
        end
        else if(rstC) begin
            i2 = 0;  // record the current coordinate (i,j) of the result matrix
            j2 = 0;  // record the current coordinate (i,j) of the result matrix
            k = 0; // middle index of  mat_A[i][k] * mat_B[k][j]   
            r = 0; // counting index 
            state_cal = 0; // mul state -> cal1 -> cal2 -> cal3 // each clk do one state
        end
        else if(startC) begin
            case(state_cal) 
                0: begin  // product
                    // mat_A and mat_B were being reorganized the datas at reading part.
                    // so it can multiply the corresponding position between mat_A and mat_B directly.
                    for(k = 0; k < 16; k = k + 1) begin
                        A[k] = mat_A[i2 * MAX_SIZE + k];
                        B[k] = mat_B[k * MAX_SIZE + j2];
                    end         
                    state_cal = 1;// in next clock, do the sum of product
                    k = 0; // initiate k to 0 in order to use in next time
                end
                1: begin // sequentially adding each product in every clk
                    if(r == 0) begin
                        c_a[0] = product[0];
                        c_b[0] = product[1];
                        c_a[1] = product[2];
                        c_b[1] = product[3];
                        c_a[2] = product[4];
                        c_b[2] = product[5];
                        c_a[3] = product[6];
                        c_b[3] = product[7];
                        c_a[4] = product[8];
                        c_b[4] = product[9];
                        c_a[5] = product[10];
                        c_b[5] = product[11];
                        c_a[6] = product[12];
                        c_b[6] = product[13];
                        c_a[7] = product[14];
                        c_b[7] = product[15];

                        r = r + 1;
                    end
                    else if(r == 1) begin
                        c_a[0] = sum[0];
                        c_b[0] = sum[1];
                        c_a[1] = sum[2];
                        c_b[1] = sum[3];
                        c_a[2] = sum[4];
                        c_b[2] = sum[5];
                        c_a[3] = sum[6];
                        c_b[3] = sum[7];

                        r = r + 1;
                    end
                    else if(r == 2) begin
                        c_a[0] = sum[0];
                        c_b[0] = sum[1];
                        c_a[1] = sum[2];
                        c_b[1] = sum[3];
                    
                        r = r + 1;
                    end
                    else if(r == 3) begin
                        c_a[0] = sum[0];
                        c_b[0] = sum[1];
                    
                        state_cal = 2; // finished the sum part, so go to next state
                        r = 0; // initialize r for next time
                    end
                end
                2: begin // assign sum to result
                    mat_Result[i2 * s3 + j2] = sum[0]; // final result of mat_Result[i][j]
                    // show in the console
                    $write("%d ", mat_Result[i2 * s3 + j2]);
                    if(j2 < s3 - 1) begin
                        j2 = j2 + 1;
                    end else begin // j==s3-1, go to next row
                        j2 = 0;
                        i2 = i2 + 1;
                        $write("\n");
                    end

                    if(i2 >= s1) begin // finished the mat_mul
                        state_cal = 3; // prevent from doing any state in this always blocks
                        finishC = 1; // finish calculation, output signal
                    end else begin
                        state_cal = 0; // go back to first state to do next result
                    end      
                end
            endcase
        end
end

// Write data to external memory at specified write address
always @(posedge clk) begin
    if(rst) begin
        finishW <= 0;
        wdata <= 0;
        waddr <= 0; 
        wen <= 0;
    end
    else if(rstC) begin
        i3 <= 0;  // record the current coordinate (i,j) of the result matrix
        j3 <= 0;  // record the current coordinate (i,j) of the result matrix
        temp2 <= 0; // skip the first clk when startW = 1
    end
    else if (startW) begin // before start writing , tb will reset the index
        if(temp2 >= 2) begin // temp used for the delay problem
            wen <= 1;     // enable  writing
            if(i3 >= s1) begin // finished the mat_mul
                finishW <= 1; // finish writing, output signal                   
            end
            wdata <= mat_Result[i3 * s3 + j3]; // assign written data
            if(j3 < s3 - 1) begin
                j3 <= j3 + 1; // next column
            end
            else begin // j==s3-1, go to next row
                j3 <= 0;
                i3 <= i3 + 1; // next row
            end
            
            
            if(temp2 == 2) begin
                j3 <= 0;    
                waddr <= 0;            
            end
            else if(temp2 > 3) begin
                waddr <= waddr + 1; // write in next address in the memory
            end
            temp2 <= temp2 + 1;
        end
        else begin
            temp2 <= temp2 + 1;
        end
    end
end

endmodule