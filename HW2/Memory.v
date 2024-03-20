`timescale 1ns / 1ps
module Memory(
    // input start, // Start signal to initiate memory access
    input [15:0] waddr, // Write address input
    input [31:0] wdata, // Write data input
    input wen, // Write enable signal
    input [1:0] sizes, // Size of the rdata bytes
    input [15:0] raddr, // Read address input
    input ren, // Read enable signal
    output reg [31:0] rdata, // Read data output
    input clk, // Clock signal
    input rst // Reset signal
);
reg [31:0] mem [0:255]; // 256x16-bit internal memory
initial begin
    mem[0] = 1;
    mem[1] = 5;
    mem[2] = 6; 
    mem[3] = 7; 

    mem[4] = 8; 
    mem[5] = 9; 
    mem[6] = 10; 
    mem[7] = 11;

    mem[8] = 13; 
    mem[9] = 10; 
    mem[10] = 11; 
    mem[11] = 13;

    mem[12] = 1;
    mem[13] = 1;
    mem[14] = 1;
    mem[15] = 1;

    mem[16] = 1;
    mem[17] = 1;
    mem[18] = 1;
    mem[19] = 1;

    mem[20] = 1;
    mem[21] = 1;
    mem[22] = 1;
    mem[23] = 1;

    mem[24] = 1;
    mem[25] = 1;
    mem[26] = 1;
    mem[27] = 1;

    mem[28] = 1;
    mem[29] = 1;
    mem[30] = 1;
    mem[31] = 1;
end

always @(posedge clk) begin
    if (ren) begin
        rdata <= mem[raddr];
    end
    if (wen) begin
        mem[waddr] <= wdata;
    end
end

endmodule
