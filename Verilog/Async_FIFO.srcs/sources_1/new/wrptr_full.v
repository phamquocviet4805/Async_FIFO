`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2026 05:16:33 PM
// Design Name: 
// Module Name: wrptr_full
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


module wrptr_full #(
    parameter PTR_WIDTH = 5
    )(
    input wr_clk,
    input wr_rst_n,
    input wr_en,
    input [PTR_WIDTH-1:0] g_rptr_sync,
    output reg full,
    output reg [PTR_WIDTH-1:0] g_wptr,
    output reg [PTR_WIDTH-1:0] b_wptr
    );
    
    localparam ADD_SIZE = PTR_WIDTH - 1; 

    wire [PTR_WIDTH-1:0] b_wptr_next;
    wire [PTR_WIDTH-1:0] g_wptr_next;
    wire wr_full;

    assign b_wptr_next = b_wptr + (wr_en && !full);
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
    assign wr_full = (
        g_wptr_next == {~g_rptr_sync[ADD_SIZE:ADD_SIZE-1], g_rptr_sync[ADD_SIZE-2:0]}
    );

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            b_wptr <= 0;
            g_wptr <= 0;
        end else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
        end
    end

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            full <= 1'b0;
        end else begin
            full <= wr_full;
        end
    end
        
endmodule
