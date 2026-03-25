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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Async_FIFO_tb;
    parameter DEPTH = 16;
    parameter DATA_WIDTH = 8;
    parameter PRELOAD_COUNT = 8;
    parameter STRESS_COUNT = 16;
    parameter TOTAL_TRANSFERS = PRELOAD_COUNT + STRESS_COUNT;

    reg wr_clk;
    reg wr_rst_n;
    reg rd_clk;
    reg rd_rst_n;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;

    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;

    reg [DATA_WIDTH-1:0] exp_mem [0:TOTAL_TRANSFERS-1];
    reg [DATA_WIDTH-1:0] exp_data;
    integer wr_count;
    integer rd_count;
    integer i;
    integer wr_idx;
    integer rd_idx;
    integer pass_count;

    TOP #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    always #10 wr_clk = ~wr_clk;
    always #35 rd_clk = ~rd_clk;

    task write_word;
        input [DATA_WIDTH-1:0] value;
        begin
            while (full) begin
                @(posedge wr_clk);
            end

            @(negedge wr_clk);
            wr_en = 1'b1;
            data_in = value;

            @(posedge wr_clk);
            exp_mem[wr_count] = value;
            wr_count = wr_count + 1;

            @(negedge wr_clk);
            wr_en = 1'b0;
            data_in = {DATA_WIDTH{1'b0}};
        end
    endtask

    task read_and_check;
        begin
            while (empty) begin
                @(posedge rd_clk);
            end

            exp_data = exp_mem[rd_count];

            @(negedge rd_clk);
            rd_en = 1'b1;

            @(posedge rd_clk);
            #1;
            if (data_out !== exp_data) begin
                $error(
                    "Time=%0t Read mismatch at index %0d: expected=%h actual=%h",
                    $time,
                    rd_count,
                    exp_data,
                    data_out
                );
            end else begin
                pass_count = pass_count + 1;
                $display(
                    "Time=%0t Read pass at index %0d: data=%h",
                    $time,
                    rd_count,
                    data_out
                );
            end

            rd_count = rd_count + 1;

            @(negedge rd_clk);
            rd_en = 1'b0;
        end
    endtask

    initial begin
        wr_clk = 1'b0;
        wr_rst_n = 1'b0;
        rd_clk = 1'b0;
        rd_rst_n = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        data_in = {DATA_WIDTH{1'b0}};
        exp_data = {DATA_WIDTH{1'b0}};
        wr_count = 0;
        rd_count = 0;
        pass_count = 0;
    end

    initial begin
        repeat (4) @(posedge wr_clk);
        wr_rst_n = 1'b1;
    end

    initial begin
        repeat (4) @(posedge rd_clk);
        rd_rst_n = 1'b1;
    end

    initial begin
        wait (wr_rst_n && rd_rst_n);

        repeat (2) @(posedge wr_clk);

        for (i = 0; i < PRELOAD_COUNT; i = i + 1) begin
            write_word(i[DATA_WIDTH-1:0]);
        end

        repeat (3) @(posedge rd_clk);

        for (i = 0; i < PRELOAD_COUNT; i = i + 1) begin
            read_and_check;
        end

        fork
            begin
                for (wr_idx = 0; wr_idx < STRESS_COUNT; wr_idx = wr_idx + 1) begin
                    write_word($random);
                end
            end
            begin
                for (rd_idx = 0; rd_idx < STRESS_COUNT; rd_idx = rd_idx + 1) begin
                    read_and_check;
                end
            end
        join

        repeat (4) @(posedge rd_clk);

        if (!empty) begin
            $error("FIFO should be empty at end of test");
        end

        $display("Simulation completed with %0d successful read checks.", pass_count);
        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "Timeout waiting for testbench completion");
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, Async_FIFO_tb);
    end

endmodule
