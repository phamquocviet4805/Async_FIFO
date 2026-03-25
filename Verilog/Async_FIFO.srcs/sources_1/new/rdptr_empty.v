`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2026 05:16:47 PM
// Design Name: 
// Module Name: rdptr_empty
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


module rdptr_empty #(parameter PTR_WIDTH = 4)(
    input rd_clk,
    input rd_rst_n,
    input rd_en,
    input [PTR_WIDTH:0] g_wptr_sync,
    output reg empty,
    output reg [PTR_WIDTH:0] g_rptr,
    output reg [PTR_WIDTH:0] b_rptr
    );

    wire [PTR_WIDTH:0] b_rptr_next;
    wire [PTR_WIDTH:0] g_rptr_next;
    wire rd_empty;

    assign b_rptr_next = b_rptr + (rd_en && !empty);
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    assign rd_empty = (g_wptr_sync == g_rptr_next);

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
        end else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            empty <= 1;
        end else begin
            empty <= rd_empty;
        end
    end

endmodule
