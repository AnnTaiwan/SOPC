`timescale 1ns / 1ps
module Memory(
    // input start, // Start signal to initiate memory access
    input [15:0] waddr, // Write address input
    input [31:0] wdata, // Write data input
    input wen, // Write enable signal
    input [15:0] raddr, // Read address input
    input ren, // Read enable signal
    output reg [31:0] rdata, // Read data output
    output [15:0] sizes, // Size of the rdata bytes
    input clk, // Clock signal
    input rst // Reset signal
);
reg [31:0] mem [0:255]; // 256x16-bit internal memory
initial begin
    mem[0] = 0;
    mem[1] = 1;
    mem[2] = 2;
    mem[3] = 3;
    mem[4] = 4;
    mem[5] = 5;
    mem[6] = 6;
    mem[7] = 7;
    mem[8] = 8;
    mem[9] = 9;
    mem[10] = 10;
    mem[11] = 11;
    mem[12] = 12;
    mem[13] = 13;
    mem[14] = 14;
    mem[15] = 15;
    mem[16] = 16;
    mem[17] = 17;
    mem[18] = 18;
    mem[19] = 19;
    mem[20] = 20;
    mem[21] = 21;
    mem[22] = 22;
    mem[23] = 23;
    mem[24] = 24;
    mem[25] = 25;
    mem[26] = 26;
    mem[27] = 27;
    mem[28] = 28;
    mem[29] = 29;
    mem[30] = 30;
    mem[31] = 31;
end

always @(posedge clk) begin
    if (ren) begin
        rdata <= mem[raddr];
    end else if (wen) begin
        mem[waddr] <= wdata;
    end else begin
        rdata = 4'bzzzz;
    end
end

endmodule