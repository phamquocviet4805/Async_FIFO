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
// Read-pointer control for the asynchronous FIFO. This module advances the
// read pointer and generates the `empty` flag in the read clock domain.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// The module keeps both binary and Gray-coded read pointers. Empty is detected
// by comparing the next Gray read pointer against the synchronized write pointer.
// 
//////////////////////////////////////////////////////////////////////////////////


module rdptr_empty #(parameter PTR_WIDTH = 5)(
    input rd_clk,
    input rd_rst_n,
    input rd_en,
    input [PTR_WIDTH-1:0] g_wptr_sync,
    output reg empty,
    output reg [PTR_WIDTH-1:0] g_rptr,
    output reg [PTR_WIDTH-1:0] b_rptr
    );

    localparam ADD_SIZE = PTR_WIDTH - 1;

    wire [PTR_WIDTH-1:0] b_rptr_next;
    wire [PTR_WIDTH-1:0] g_rptr_next;
    wire rd_empty;

    // Advance only when a read is requested and the FIFO is not empty.
    assign b_rptr_next = b_rptr + (rd_en && !empty);
    // Convert the next binary pointer into Gray code for CDC-safe comparison.
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    // FIFO is empty when the next read pointer catches the synchronized write pointer.
    assign rd_empty = (g_wptr_sync == g_rptr_next);

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
        end else begin
            // Update both pointer forms together each read clock.
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            empty <= 1;
        end else begin
            // Register the empty flag to keep it aligned with read-domain timing.
            empty <= rd_empty;
        end
    end

endmodule
