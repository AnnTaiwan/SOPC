`timescale 1ns / 1ps
module Mat_mul_16bits_4x4_4x4(
    input startR, // Start signal to initiate memory access
    input startC, // Start signal to calculation
    input startW, // Start signal to write memory
    input [31:0] rdata, // Read data output
//    input [1:0] sizes, // Size selection for read/write operations
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
reg [3:0] i, j, k;
wire [31:0] product; // record the  mul result temporarily
reg [1:0] sizes;
//Read data
initial begin 
    i = 0; 
    j = 0; 
    k = 0;
    raddr = 0;
    finishR = 0;
    finishC = 0;
    finishW = 0;
    wdata = 0;
    waddr = 0; 
    wen = 0;
end
// Read data to external memory at specified read address
Memory R1(.waddr(waddr), .wdata(wdata), .wen(wen), .sizes(sizes), .raddr(raddr), .ren(ren), .rdata(rdata), .clk(clk), .rst(rst));
always @(posedge clk) begin
    if (startR) begin
        ren <= 1;
        sizes <= 2;// each number is 2 bytes, read from the memory
        if(i < 16) begin
            mat_A[i] <= rdata[15:0];
        end else if (i >= 16 && i < 32) begin
            mat_B[i - 16] <= rdata[15:0];
        end
        if(i >= 32) begin
            //?•¶?Ž¥?”¶?ˆ°finsihR == 1, testbench ?Ž§?ˆ¶startR, ren = 0, 
            i <= 0; // ??žé˜»å¡žè³¦?? (<=)
            finishR <= 1;
        end else begin
            i <= i + 1;
            raddr <= raddr + 1;
        end
    end
end

//start to multiply mat_A and mat_B, use i to indicate the level of multiplication finishment of mat_rmat_Resultesult
MUL16 m1(.A(A), .B(B), .Product(product));
always @(posedge clk) begin
    if (startC) begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                mat_Result[i*4+j] <= 0;        
                for (k = 0; k < 4; k = k + 1) begin
                    A <= mat_A[i*4+k];
                    B <= mat_B[k*4+j];
                    mat_Result[i*4+j] <= mat_Result[i*4+j] + product;                   
                end
            end
        end
        i <= 32; // ?œ¨??å?‹å?–ç‚º32, ?‚ºäº†ä?‹å?Œç?„write to memory
        finishC <= 1;
    end
end

// Write data to external memory at specified write address
Memory W1(.waddr(waddr), .wdata(wdata), .wen(wen), .sizes(sizes), .raddr(raddr), .ren(ren), .rdata(rdata), .clk(clk), .rst(rst));
always @(posedge clk) begin
    if (startW) begin
        wen <= 1;
        sizes <= 2;// result number is 4 bytes, write to memory
        if(i < 16) begin
            wdata <= mat_Result[i];
            waddr <= i;
        end
        if (i >= 16) begin
            i <= 0;
            finishW <= 1;
        end else begin
            i <= i + 1;
        end
    end
end

endmodule
