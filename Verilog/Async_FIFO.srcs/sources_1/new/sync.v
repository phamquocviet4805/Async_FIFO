`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2026 05:13:02 PM
// Design Name: 
// Module Name: sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sync #(parameter SIZE = 3)(
    output reg [SIZE-1:0] data_out,
    input [SIZE-1:0] data_in,
    input clk, rst_n
    );

    reg [SIZE-1:0] ff_1;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ff_1 <= 0;
            data_out <= 0;
        end
        else begin
            ff_1 <= data_in;
            data_out <= ff_1;
        end 
    end
    
endmodule
