`timescale 1ns / 1ps 
module top(
    input wire clk, // Clock signal
    input rst, // Reset signal
    input start, // start the whole process
//    input startR, // activate this whole process
    // input rstC, rstMemory, rstMemory2,
    input [4:0] size1, size2, size3
    // output [2:0] state_cal;
);
    reg startR, startC, startW;
    // reg  rstC;
    // reg [4:0] size1, size2, size3;
    wire [2:0] state_cal;
    // below __Name__2 wire is used for output memory, the other is for input memory.
    wire [31:0] rdata, rdata2;
    wire [31:0] wdata, wdata2;
    wire [15:0] raddr, waddr, raddr2, waddr2;
    wire ren, wen, ren2, wen2;
    wire [15:0] sizes, sizes2;
    wire finishR, finishC, finishW;
    reg rstMemory, rstMemory2; // tb can reset the memory if needed
    
    Mat_Mul_16bits mat_mul1(
        .startR(startR),
        .startC(startC),
        .startW(startW),
        .rdata(rdata),
        .sizes(sizes),
        .clk(clk),
        .rst(rst),
//        .rstC(rstC),
        .size1(size1),
        .size2(size2),
        .size3(size3),
        .state_cal(state_cal),
        .raddr(raddr),
        .ren(ren),
        .finishR(finishR),
        .finishC(finishC),
        .finishW(finishW),
        .wdata(wdata2),
        .waddr(waddr2),
        .wen(wen2)
    );
    Memory InputMem1(.waddr(waddr), .wdata(wdata), .wen(wen), .raddr(raddr), .ren(ren), .rdata(rdata), .sizes(sizes), .clk(clk), .rst(rst), .rstMemory(rstMemory));
    Memory OutputMem2(.waddr(waddr2), .wdata(wdata2), .wen(wen2), .raddr(raddr2), .ren(ren2), .rdata(rdata2), .sizes(sizes2), .clk(clk), .rst(rst), .rstMemory(rstMemory2));
      
    always @(posedge clk or posedge rst) begin
        if(start && finishR == 0) begin // start has to be det to 0, or it will keep reading memory
            startR <= 1;
            startC <= 0;
            startW <= 0;
        end
        
        if(rst) begin
            startR <= 0;
            startC <= 0;
            startW <= 0;
            rstMemory2 <= 1; // reset the outpur memory
        end
        else begin
            if(finishR == 1 && finishC == 0) begin
                startC <= 1;
                startR <= 0;
                startW <= 0;
            end
            if(finishC == 1 && finishW == 0) begin
                startW <= 1;
                startC <= 0;
                startR <= 0;

            end
            if(finishW == 1) begin
                startW <= 0;
                startC <= 0;
                startR <= 0;
            end
        end
    end
    
endmodule