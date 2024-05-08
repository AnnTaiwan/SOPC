`timescale 1ns / 1ps 
module tb_mat_mul();
    parameter MAX_SIZE = 13;
    parameter SQU_MAX_SIZE = 169;
    parameter DATA_BW = 16;
    reg clk;
    reg rst;
    reg start;
    // input [4:0] size1, size2, size3, // mat_A is size1 * size1, mat_B is size2 * size3.
    reg [SQU_MAX_SIZE * DATA_BW-1:0] data_inA;
    reg [SQU_MAX_SIZE * DATA_BW-1:0] data_inB;
    wire [SQU_MAX_SIZE * DATA_BW*2-1:0] data_out;
    wire finish;
    
    integer h, k;

    Mat_Mul_16bits MUL1(
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_inA(data_inA),
        .data_inB(data_inB),
        .data_out(data_out),
        .finish(finish)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
                data_inA[h*DATA_BW +: DATA_BW] = h;
        end
        for(h = SQU_MAX_SIZE, k = 0; h < 2*SQU_MAX_SIZE;k = k + 1, h = h + 1) begin
                data_inB[k*DATA_BW +: DATA_BW] = h;
        end
        #10
        rst = 0;
        start = 0;
        #10
        rst = 1;
        #20
        rst = 0;
        
        
        #10
        

        start = 1;
        @(posedge finish);
        $display("Finish calculation");
        start = 0;
        for(h = 0; h < MAX_SIZE; h = h + 1) begin
            for(k = 0; k < MAX_SIZE; k = k + 1) begin
                $write("%d ", data_out[(h*MAX_SIZE + k)*2*DATA_BW +: 2*DATA_BW]);
            end
            $write("\n");
        end
        # 10
        

        
        $finish;

    end
endmodule