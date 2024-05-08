`timescale 1ns / 1ps
module Mat_Mul#(
    parameter MAX_SIZE = 13,
    parameter DATA_BW = 16,
    parameter SQU_MAX_SIZE = 169
)(
    input clk,
    input mul_rst,
    input start,
    // data put from the low place in data_inA and data_inB (increasing order)
    input [SQU_MAX_SIZE * DATA_BW - 1:0] data_inA,
    input [SQU_MAX_SIZE * DATA_BW - 1:0] data_inB,
    output reg [SQU_MAX_SIZE * DATA_BW * 2 - 1:0] data_out,
    output reg finish
);

// declare arrray
reg [DATA_BW-1:0] mat_A [0:SQU_MAX_SIZE-1], mat_B [0:SQU_MAX_SIZE-1]; // two source matrix 
reg [DATA_BW*2-1:0] mat_Result [0:SQU_MAX_SIZE-1]; //  result matrix 
reg [2:0] state_cal;
integer i2, j2, k, h, i, j; //index
reg [DATA_BW*2-1:0] product[0:MAX_SIZE-1]; // record the mul_unit result

// Mat decomposition.
// start from the result matrix's  first column
always @(posedge clk) begin
        if(mul_rst) begin
            for(h = 0; h < SQU_MAX_SIZE; h = h + 1) begin
                mat_Result[h] <= 0;
            end
            i2 <= 0;  // record the current coordinate (i,j) of the result matrix
            j2 <= 0;  // record the current coordinate (i,j) of the result matrix
            state_cal <= 0; // mul state -> cal1 -> cal2 -> cal3 // each clk do one state
            finish <= 0;
            data_out <= 10;
            for (i = 0; i < SQU_MAX_SIZE; i = i + 1) begin
                mat_A[i] <= data_inA[i*DATA_BW +: DATA_BW];
                mat_B[i] <= data_inB[i*DATA_BW +: DATA_BW];
            end
        end
        else if(start && finish == 0) begin
            case(state_cal) 
                0: begin  // product
                    for(k = 0; k < MAX_SIZE; k = k + 1) begin
                        product[k] <= mat_A[i2 * MAX_SIZE + k] * mat_B[k * MAX_SIZE + j2];
                    end         
                    state_cal <= 1;// in next clock, do the sum of product
                end
                1: begin // assign sum to result
                    mat_Result[i2 * MAX_SIZE + j2] <= product[0] + product[1] + product[2] + product[3] + 
                                               product[4] + product[5] + product[6] + product[7] + 
                                               product[8] + product[9] + product[10] + product[11] + 
                                               product[12]; // final result of mat_Result[i][j]
                    
                    state_cal <= 2; // go to next state
                end
                2 : begin
                    if(j2 < MAX_SIZE - 1) begin
                        j2 <= j2 + 1;
                    end else begin // j==MAX_SIZE-1, go to next row
                        j2 <= 0;
                        i2 <= i2 + 1;
                    end
                    if(i2 >= MAX_SIZE) begin // finished the mat_mul
                        state_cal <= 3; // prevent from doing any state in this always blocks
                        finish <= 1; // finish calculation, output signal
                    end else begin
                        state_cal <= 0; // go back to first state to do next result
                    end      
                end
            endcase
        end
        else if(finish) begin // assign the result to output port
             for (i = 0; i < SQU_MAX_SIZE; i = i + 1) begin
                data_out[i*2*DATA_BW +: 2*DATA_BW] <= mat_Result[i];
             end
        end
end
endmodule