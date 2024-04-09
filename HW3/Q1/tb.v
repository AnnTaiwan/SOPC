`timescale 1ns / 1ps 
module tb_mat_mul();
    reg startR, startC, startW;
    reg  rst, clk; //, rstC
    reg [4:0] size1, size2, size3;
    wire [2:0] state_cal;
    // below __Name__2 wire is used for output memory, the other is for input memory.
    wire [15:0] rdata, rdata2;
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
        // .rstC(rstC),
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
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reset generation
    initial begin
    $display("HAHAHAH.");
        // set the matrix size
        // mat_A is size1 * size1, mat_B is size2 * size3.
        size1 = 16;
        size2 = 16;
        size3 = 16;

        rstMemory = 0; // don't reset the input memory, preventing from deleting the initial data
        rstMemory2 = 0;
        rst = 1;
//        rstC = 0;
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
        @(posedge finishR);
        $display("Finish reading data from input memory.");
        // wait for the rising edge of the 
        // finishR signal (transition from 0 to 1). 
        // Once the finishR signal goes high, the code will continue executing the subsequent lines of code.
        startR = 0;

        // start to calculate the matrix multiplication
        

        // Start calculation
        startC = 1;
        // Wait for calculation to finish
        @(posedge finishC);
        startC = 0;
        $display("Finish matrix multiplication.");

         
//        rstC = 1; // reset the index    
        rstMemory2 = 1; // initialize the output_memory to 0
        #20
//        rstC = 0;
        rstMemory2 = 0;
        // Start write
        startW = 1;
        
       
        // Wait for write to finish
        @(posedge finishW);
        #20
        $display("Finish writig data to output memory.");
        startW = 0;
        
        // test if the wriing rersult is correct or not.
//        rst = 1;
        #20

        // End simulation
        $finish;
    end
    
endmodule