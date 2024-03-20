`timescale 1ns / 1ps 
module tb_mat_mul();
    reg startR, startC, startW;
    reg clk, rst;
    wire [15:0] rdata;
    wire [31:0] wdata;
    wire [15:0] raddr, waddr;
    wire ren, wen;
    wire [1:0] sizes;
    wire finishR, finishC, finishW;
    ////
    reg [15:0] waddr2, raddr2;
    wire [31:0] rdata2;
    reg [31:0] wdata2;
    reg wen2, ren2;
    reg [1:0] sizes2;

    
    // Instantiate the Mat_mul_16bits_4x4_4x4 module
    Mat_mul_16bits_4x4_4x4 mat_mul1(
        .startR(startR),
        .startC(startC),
        .startW(startW),
        .rdata(rdata),
//        .sizes(sizes),
        .clk(clk),
        .rst(rst),
        .raddr(raddr),
        .ren(ren),
        .finishR(finishR),
        .finishC(finishC),
        .finishW(finishW),
        .wdata(wdata),
        .waddr(waddr),
        .wen(wen)
    );
    Memory Mem1(
        .waddr(waddr2), // Write address input
        .wdata(wdata2), // Write data input
        .wen(wen2), // Write enable signal
        .sizes(sizes2), // Size of the rdata bytes
        .raddr(raddr2), // Read address input
        .ren(ren2), // Read enable signal
        .rdata(rdata2), // Read data output
        .clk(clk), // Clock signal
        .rst(rst) // Reset signal
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        rst = 1;
        #10 rst = 0;
    end

    // Testbench stimulus
    initial begin
        // Initialize signals
        clk = 0;
        startR = 0;
        startC = 0;
        startW = 0;
        
        // Wait for reset to complete
        #20;

        // Start memory access
        startR = 1;
        #10;
        

        // Wait for memory access to finish
        $display("VVVVVV");
        @(posedge finishR);
        $display("AAAA");
        // wait for the rising edge of the 
        // finishR signal (transition from 0 to 1). 
        // Once the finishR signal goes high, the code will continue executing the subsequent lines of code.
        startR = 0;

        // Start calculation
        startC = 1;
        #10;
        

        // Wait for calculation to finish
        @(posedge finishC);
        startC = 0;

        // Start write
        startW = 1;
        #10;
        

        // Wait for write to finish
        @(posedge finishW);
        startW = 0;



        // chech the memory, read from the memory, start from raddr = 32
        raddr2 = 32;
        ren2 = 1;
        wen2 = 0;
        sizes2 = 4;
        while (raddr2 <= 63) begin
            $display("at %d, Result: %d", raddr2, rdata2);
            #5;
            raddr2 = raddr2 + 1;
        end
        
        // End simulation
        $finish;
    end

endmodule

/* use for testing multiply unit
`timescale 1ns / 1ps
module testbench();
    reg [15:0] a, b; //input 16 bits
    wire [31:0] result; //output result 32 bits
    MUL16 m1(.A(a), .B(b), .Product(result));
    // Provide stimulus to the inputs
    initial begin
        // Initialize inputs
        a = 16'hABCD;
        b = 16'h2578;

        // Wait for some time
        #10;

        // Display inputs
        $display("First, Input A: %h, Input B: %h", a, b);

        // Wait for some time
        #10;

        // Display the result
        $display("Result: %h", result);

        a = 16'hEF12;
        b = 16'h8451;

        // Wait for some time
        #10;

        // Display inputs
        $display("Second, Input A: %h, Input B: %h", a, b);

        // Wait for some time
        #10;

        // Display the result
        $display("Result: %h", result);
        // Finish simulation
        $finish;
    end
endmodule
*/