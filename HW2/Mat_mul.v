`timescale 1ns / 1ps
module InputMemory(
    input start, // Start signal to initiate memory access
    input [15:0] raddr, // Read address input
    input ren, // Read enable signal
    input [1:0] sizes, // Size of the rdata bytes
    input clk, // Clock signal
    input rst, // Reset signal
    input finish, // Finish signal to indicate completion of memory access
    output reg [15:0] rdata // Read data output
);

reg [15:0] mem [0:255]; // 256x15-bit internal memory

assign mem[0] = 1;
assign mem[1] = 5; 
assign mem[2] = 6; 

assign mem[3] = 7; 
assign mem[4] = 8; 
assign mem[5] = 9; 

assign mem[6] = 10; 
assign mem[7] = 11; 
assign mem[8] = 13; 

// Read data from external memory based on read address input
always @(posedge clk) begin
    if (start && ren) begin
        // Perform read operation from internal memory
        rdata <= mem[raddr];
    end
end
endmodule

module OutputMemory(
    input start, // Start signal to initiate memory access
    input [15:0] waddr, // Read address input
    input [15:0] wdata,
    input wen, // Read enable signal
    input [1:0] sizes, // Size of the rdata bytes
    input clk, // Clock signal
    input rst, // Reset signal
    input finish, // Finish signal to indicate completion of memory access
);

reg [15:0] mem [0:255]; // 256x15-bit internal memory


// Write data to external memory at specified write address
always @(posedge clk) begin
    if (start && wen) begin
        // Perform write operation to external memory
        mem[waddr] <= wdata;
    end
end

endmodule
/* generally use reg for outputs, 
intermediate signals within your module, 
and variables that need to retain their values across clock cycles.
*/
module Mat_mul(
    input startR, // Start signal to initiate memory access
    input startC, // Start signal to calculation
    input startW, // Start signal to write memory 

    input [15:0] rdata, // Read data output
    input [1:0] sizes, // Size selection for read/write operations
    input clk, // Clock signal
    input rst, // Reset signal
    
    output [15:0] raddr, // Read address input
    output ren, // Read enable signal

    output finish, // Finish signal to indicate completion of memory access
    output reg [15:0] wdata, // Write data input
    output reg [15:0] waddr, // Write address input
    output wen // Write enable signal
);

reg [15:0] mat_A [0:8], mat_B [0:8]; // two matrix 3*3
reg [31:0] mat_Result [0:8]; //  matrix 3*3
reg [15:0] i;
//Read data
i <= 0;
// Write data to external memory at specified write address
always @(posedge clk) begin
    if (startR && ren) begin
        InputMemory R1(.start(startR), .raddr(raddr), .ren(ren), .sizes(sizes), .clk(clk), .rst(rst), .finish(finish), .rdata(rdata))
        if(i < 9) begin
            mat_A[i] <= rdata;
        end
        else begin
            mat_B[i] <= rdata;
        end
        i += 1;
        if(i >= 18) begin
            startR <= 0;
            ren <= 0;
            startC <= 1;
        end
    end
end


endmodule
