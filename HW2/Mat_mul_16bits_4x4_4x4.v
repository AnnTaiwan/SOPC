`timescale 1ns / 1ps
module Mat_mul_16bits_4x4_4x4(
    input startR, // Start signal to initiate memory access
    input startC, // Start signal to calculation
    input startW, // Start signal to write memory
    input [31:0] rdata, // Read data output
    input [15:0] sizes, // Size selection for read/write operations
    input clk, // Clock signal
    input rst, // Reset signal
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
reg [15:0] A, B;
reg [31:0] mat_Result [0:15]; //  matrix 4*4
reg [15:0] i, j, k;
wire [31:0] product; // record the  mul result temporarily
//reg [15:0] rdata_reg; // 用于存??取到的?据的寄存器
//Read data
initial begin 
    i = 0; 
    j = 0; 
    k = 0;
    ren = 0;
    raddr = 0;
    finishR = 0;
    finishC = 0;
    finishW = 0;
    wdata = 0;
    waddr = 0; 
    wen = 0;
    
    mat_A[0] = 0;
    mat_A[1] = 1;
    mat_A[2] = 2;
    mat_A[3] = 3;
    mat_A[4] = 4;
    mat_A[5] = 5;
    mat_A[6] = 6;
    mat_A[7] = 7;
    mat_A[8] = 8;
    mat_A[9] = 9;
    mat_A[10] = 10;
    mat_A[11] = 11;
    mat_A[12] = 12;
    mat_A[13] = 13;
    mat_A[14] = 14;
    mat_A[15] = 15;
    mat_B[0] = 16;
    mat_B[1] = 17;
    mat_B[2] = 18;
    mat_B[3] = 19;
    mat_B[4] = 20;
    mat_B[5] = 21;
    mat_B[6] = 22;
    mat_B[7] = 23;
    mat_B[8] = 24;
    mat_B[9] = 25;
    mat_B[10] = 26;
    mat_B[11] = 27;
    mat_B[12] = 28;
    mat_B[13] = 29;
    mat_B[14] = 30;
    mat_B[15] = 31;

end
// Read data to external memory at specified read address
//Memory R1(.waddr(waddr), .wdata(wdata), .wen(wen), .sizes(sizes), .raddr(raddr), .ren(ren), .rdata(rdata), .clk(clk), .rst(rst));
always @(posedge clk) begin
    if (startR) begin
        ren = 1;
        if(i >= 0 && i < 16) begin
//            mat_A[i] = rdata[15:0];
            $display("rdata: %d", rdata[15:0]);
            $display("raddr: %d", raddr);
            $display("mat_A  (%d): %d", i, mat_A[i]);
        end else if (i >= 16 && i < 32) begin
//            mat_B[i - 16] = rdata[15:0];
            $display("rdata: %d", rdata[15:0]);
            $display("raddr: %d", raddr);
             $display("mat_B  (%d): %d", i, mat_B[i-16]);
        end
        if(i >= 32) begin
            //finished read data
            i <= 0; // initialize i to 0
            ren <= 0;
            finishR <= 1; // output signal to let the tb know can start doing calculation
        end else begin
            i <= i + 1;
            raddr <= raddr + 1;
//            rdata_reg <= rdata[15:0];
        end
    end
end
reg C_in;
reg [31:0] c_a, c_b;
wire [31:0] sum;
wire C_out;
//start to multiply mat_A and mat_B, use i to indicate the level of multiplication finishment of mat_rmat_Resultesult
MUL16 m1(.A(A), .B(B), .Product(product));
CLA_32_bit C1(.C_in(1'b0), .A(c_a), .B(c_b), .C_out(c_cout), .Sum(sum));
always @(*) begin
    if (startC) begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                mat_Result[i*4+j] = 0;        
                for (k = 0; k < 4; k = k + 1) begin
                    A = mat_A[i*4+k];
                    B = mat_B[k*4+j];
                    $display("(%d, %d): %d", A, B, product);
                    c_a = mat_Result[i*4+j];
                    c_b = product;
                    mat_Result[i*4+j] = sum;       
                end
                $display("Result at (%d, %d): %d", i, j, mat_Result[i*4+j]);
            end
        end
        //  finished calculation
        i <= 32; // ready to write data
        finishC <= 1; // output signal
    end
end

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
