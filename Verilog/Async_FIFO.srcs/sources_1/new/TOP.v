`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2026 05:17:07 PM
// Design Name: 
// Module Name: TOP
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


module TOP #(
    parameter DEPTH = 16,
    parameter DATA_WIDTH = 8
) (
    input wr_clk,
    input wr_rst_n,
    input rd_clk,
    input rd_rst_n,
    input wr_en,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
    );

    localparam PTR_WIDTH = $clog2(DEPTH) + 1;

    wire [PTR_WIDTH-1:0] g_wptr_sync;
    wire [PTR_WIDTH-1:0] g_rptr_sync;
    wire [PTR_WIDTH-1:0] b_wptr;
    wire [PTR_WIDTH-1:0] b_rptr;
    wire [PTR_WIDTH-1:0] g_wptr;
    wire [PTR_WIDTH-1:0] g_rptr;

    sync #(PTR_WIDTH) sync_wptr_inst (
        .data_out(g_wptr_sync),
        .data_in(g_wptr),
        .clk(rd_clk),
        .rst_n(rd_rst_n)
    );

    sync #(PTR_WIDTH) sync_rptr_inst (
        .data_out(g_rptr_sync),
        .data_in(g_rptr),
        .clk(wr_clk),
        .rst_n(wr_rst_n)
    );

    wrptr_full #(PTR_WIDTH) wptr_full_inst (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .g_rptr_sync(g_rptr_sync),
        .full(full),
        .g_wptr(g_wptr),
        .b_wptr(b_wptr)
    );

    rdptr_empty #(PTR_WIDTH) rptr_empty_inst (
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .g_wptr_sync(g_wptr_sync),
        .empty(empty),
        .g_rptr(g_rptr),
        .b_rptr(b_rptr)
    );

    fifo_mem #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) fifo_mem_inst (
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .b_wptr(b_wptr),
        .b_rptr(b_rptr),
        .data_in(data_in),
        .full(full),
        .empty(empty),
        .data_out(data_out)
    );

endmodule
