`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03/25/2026 08:26:00 PM
// Design Name:
// Module Name: Async_FIFO_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
// Basic behavioral testbench for the asynchronous FIFO. It applies reset,
// performs write/read traffic, and exercises full and empty corner cases.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// The two clocks run at different rates to mimic asynchronous operation.
//
//////////////////////////////////////////////////////////////////////////////////


module Async_FIFO_tb;

    parameter DSIZE = 8;
    parameter DEPTH = 16;

    reg [DSIZE-1:0] wr_data;
    reg w_inc;
    reg r_inc;
    reg wr_clk;
    reg rd_clk;
    reg wr_rst_n;
    reg rd_rst_n;

    wire [DSIZE-1:0] rd_data;
    wire wr_full;
    wire rd_empty;

    integer i;
    integer seed;

    TOP #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DSIZE)
    ) fifo (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .wr_en(w_inc),
        .rd_en(r_inc),
        .data_in(wr_data),
        .data_out(rd_data),
        .full(wr_full),
        .empty(rd_empty)
    );

    // Write clock is faster than read clock in this testbench.
    always #5  wr_clk = ~wr_clk;
    always #10 rd_clk = ~rd_clk;

    always @(posedge wr_clk) begin
        if (w_inc && !wr_full) begin
            $display("Time=%0t WRITE data=%h full=%b empty=%b", $time, wr_data, wr_full, rd_empty);
        end else if (w_inc && wr_full) begin
            $display("Time=%0t WRITE blocked because FIFO is full", $time);
        end
    end

    always @(posedge rd_clk) begin
        if (r_inc && !rd_empty) begin
            $display("Time=%0t READ  data=%h full=%b empty=%b", $time, rd_data, wr_full, rd_empty);
        end else if (r_inc && rd_empty) begin
            $display("Time=%0t READ blocked because FIFO is empty", $time);
        end
    end

    initial begin
        // Initialize signals before pulsing the active-low resets.
        i = 0;
        seed = 1;
        wr_clk = 1'b0;
        rd_clk = 1'b0;
        wr_rst_n = 1'b1;
        rd_rst_n = 1'b1;
        w_inc = 1'b0;
        r_inc = 1'b0;
        wr_data = {DSIZE{1'b0}};

        #40;
        wr_rst_n = 1'b0;
        rd_rst_n = 1'b0;

        #40;
        wr_rst_n = 1'b1;
        rd_rst_n = 1'b1;

        // Write while read is enabled to show normal FIFO flow.
        $display("TEST CASE 1: Write data and read it back");
        r_inc = 1'b1;
        for (i = 0; i < 10; i = i + 1) begin
            wr_data = $random(seed) % 256;
            w_inc = 1'b1;
            #10;
            w_inc = 1'b0;
            #10;
        end

        // Continue writing past capacity and observe the full protection.
        $display("TEST CASE 2: Fill FIFO and try to write more");
        r_inc = 1'b0;
        w_inc = 1'b1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            wr_data = $random(seed) % 256;
            #10;
        end
        w_inc = 1'b0;

        // Read past the remaining contents and observe the empty protection.
        $display("TEST CASE 3: Empty FIFO and try to read more");
        r_inc = 1'b1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            #20;
        end
        r_inc = 1'b0;

        #40;
        $finish;
    end

//    initial begin
//        $dumpfile("dump.vcd");
//        $dumpvars(0, Async_FIFO_tb);
//    end

endmodule
