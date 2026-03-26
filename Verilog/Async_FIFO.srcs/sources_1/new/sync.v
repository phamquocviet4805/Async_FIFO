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


module sync #(parameter SIZE = 5)(
    output reg [SIZE-1:0] data_out,
    input [SIZE-1:0] data_in,
    input clk,
    input rst_n
    );

    reg [SIZE-1:0] ff_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {data_out, ff_1} <= 0; 
        end else begin
            {data_out, ff_1} <= {ff_1, data_in}; 
        end
    end

endmodule
