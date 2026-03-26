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
// Two-flop synchronizer used to transfer a Gray-coded pointer into a new
// clock domain inside the asynchronous FIFO.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This module is intended for Gray-coded CDC paths. Gray code changes only
// one bit at a time, which makes multi-bit pointer synchronization safer.
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
            // Clear both synchronizer stages when the local reset is asserted.
            {data_out, ff_1} <= 0; 
        end else begin
            // Stage 1 captures the incoming bus; stage 2 provides a settled
            // version to logic in this clock domain.
            {data_out, ff_1} <= {ff_1, data_in}; 
        end
    end

endmodule
