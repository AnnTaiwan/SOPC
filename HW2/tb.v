`timescale 1ns / 1ps 
module tb_mat_mul();
    reg startR, startC, startW;
    reg clk, rst, rstC;
    reg [4:0] size1, size2, size3;
    wire [2:0] state_cal;
    wire [15:0] rdata;
    wire [31:0] wdata;
    wire [15:0] raddr, waddr;
    wire ren, wen;
    wire [15:0] sizes;
    wire finishR, finishC, finishW;
//    ////
//    reg [15:0] waddr2, raddr2;
//    wire [31:0] rdata2;
//    reg [31:0] wdata2;
//    reg wen2, ren2;
//    reg [1:0] sizes2;

    
    // Instantiate the Mat_mul_16bits_4x4_4x4 module
    // Mat_mul_16bits_4x4_4x4 mat_mul1(
    //     .startR(startR),
    //     .startC(startC),
    //     .startW(startW),
    //     .rdata(rdata),
    //     .sizes(sizes),
    //     .clk(clk),
    //     .rst(rst),
    //     .rstC(rstC),
    //     .state_cal(state_cal),
    //     .raddr(raddr),
    //     .ren(ren),
    //     .finishR(finishR),
    //     .finishC(finishC),
    //     .finishW(finishW),
    //     .wdata(wdata),
    //     .waddr(waddr),
    //     .wen(wen)
    // );
    Mat_Mul_16bits mat_mul1(
        .startR(startR),
        .startC(startC),
        .startW(startW),
        .rdata(rdata),
        .sizes(sizes),
        .clk(clk),
        .rst(rst),
        .rstC(rstC),
        .size1(size1),
        .size2(size2),
        .size3(size3),
        .state_cal(state_cal),
        .raddr(raddr),
        .ren(ren),
        .finishR(finishR),
        .finishC(finishC),
        .finishW(finishW),
        .wdata(wdata),
        .waddr(waddr),
        .wen(wen)
    );
    Memory Mem1(.waddr(waddr), .wdata(wdata), .wen(wen), .raddr(raddr), .ren(ren), .rdata(rdata), .sizes(sizes), .clk(clk), .rst(rst));
    Memory Mem2(.waddr(waddr), .wdata(wdata), .wen(wen), .raddr(raddr), .ren(ren), .rdata(rdata), .sizes(sizes), .clk(clk), .rst(rst));
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        // set the matrix size
        size1 = 4;
        size2 = 5;
        size3 = 6;

        rst = 1;
        rstC = 0;
        #15 
        rst = 0;
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
        // Wait for memory access to finish
        $display("VVVVVV");
        @(posedge finishR);
        $display("AAAA");
        // wait for the rising edge of the 
        // finishR signal (transition from 0 to 1). 
        // Once the finishR signal goes high, the code will continue executing the subsequent lines of code.
        startR = 0;

        // start to calculate the 4x4_4x4 matrix multiplication
        rstC = 1; // reset the index        
        #20
        rstC = 0;
/////////////////////////////////
         // Start calculation
         startC = 1;
         // Wait for calculation to finish
         @(posedge finishC);
         // #5
         startC = 0;
         $display("CCCC");
         // Start write
         startW = 1;
       
         // Wait for write to finish
         @(posedge finishW);
         $display("WWWW");
         startW = 0;
//////////////////////////////


//        // chech the memory, read from the memory, start from raddr = 32
//        raddr2 = 32;
//        ren2 = 1;
//        wen2 = 0;
//        sizes2 = 4;
//        while (raddr2 <= 63) begin
//            $display("at %d, Result: %d", raddr2, rdata2);
//            #5;
//            raddr2 = raddr2 + 1;
//        end
        
        // End simulation
        $finish;
    end

endmodule