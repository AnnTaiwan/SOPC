`timescale 1ns / 1ps
module Memory(
    // input start, // Start signal to initiate memory access
    input [15:0] waddr, // Write address input
    input [31:0] wdata, // Write data input
    input wen, // Write enable signal
    input [15:0] raddr, // Read address input
    input ren, // Read enable signal
    output reg [31:0] rdata, // Read data output
    output reg [15:0] sizes, // the number of bytes: the size of the data being read or written. One data in this memory is 32bits(4bytes)
    input clk, // Clock signal
    input rst, // Reset signal
    input rstMemory // Reset memory to 0
);
reg [31:0] mem [0:1023]; // 1024x16-bit internal memory
integer i;
initial begin
    for(i = 0; i < 1024; i = i + 1) begin
        mem[i] = i;
    end
end

// reset the output signal
always @(posedge clk or posedge rst) begin
    if(rst) begin
        rdata <= 32'bz;
        sizes <= 15'bz;
        // Can use for print the final result in the end of the tb process by setting rst 1 and wait #10 to finish.
        // for(i = 0; i < 64; i = i + 1) begin
        //     $write("%d ",mem[i]); 
        //     if(i % 8 == 7) begin
        //         $write("\n"); 
        //     end
           
        // end
    end
end
always @(posedge clk or posedge rstMemory) begin
    if(rstMemory) begin
        for(i = 0; i < 1024; i = i + 1) begin
            mem[i] = 0;
        end
    end
end

always @(posedge clk) begin
    if (ren) begin
        rdata <= mem[raddr];
        sizes <= 4; // 4 bytes
    end else if (wen) begin
        mem[waddr] <= wdata;
        sizes <= 4;
    end else begin // nothing
        rdata = 32'bz;
        sizes <= 4;
    end
end

endmodule
