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
// Write-pointer control for the asynchronous FIFO. This module advances the
// write pointer and generates the `full` flag in the write clock domain.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// The module keeps both binary and Gray-coded write pointers. Gray code is
// compared against the synchronized read pointer to detect a full condition.
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

    // Advance only when a write is requested and the FIFO is not full.
    assign b_wptr_next = b_wptr + (wr_en && !full);
    // Convert the next binary pointer into Gray code for CDC-safe comparison.
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
    // FIFO becomes full when the next write pointer reaches the read pointer
    // with the wrap bits inverted.
    assign wr_full = (
        g_wptr_next == {~g_rptr_sync[ADD_SIZE:ADD_SIZE-1], g_rptr_sync[ADD_SIZE-2:0]}
    );

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            b_wptr <= 0;
            g_wptr <= 0;
        end else begin
            // Update both pointer forms together each write clock.
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
        end
    end

    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            full <= 1'b0;
        end else begin
            // Register the full flag to keep it aligned with write-domain timing.
            full <= wr_full;
        end
    end
        
endmodule
