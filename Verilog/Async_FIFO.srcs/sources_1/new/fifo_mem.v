`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2026 05:13:47 PM
// Design Name: 
// Module Name: fifo_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
// Storage array for the asynchronous FIFO. The write side updates memory on
// `wr_clk`, and the read side exposes the selected entry from the read pointer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Only the lower pointer bits address the RAM. The extra MSB in each pointer
// is used by the full/empty logic to track wrap-around.
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter PTR_WIDTH = 5,
    parameter DEPTH = 16 
)(
    input wr_clk,
    input wr_en,
    input rd_clk,
    input rd_en,
    input [PTR_WIDTH-1:0] b_wptr,
    input [PTR_WIDTH-1:0] b_rptr,
    input [DATA_WIDTH-1:0] data_in,
    input full,
    input empty,
    output [DATA_WIDTH-1:0] data_out
    );
    
    localparam ADD_SIZE = PTR_WIDTH - 1;

    // FIFO storage depth is indexed by the binary address bits only.
    reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1];
    
    always @(posedge wr_clk) begin
        if (wr_en && !full) begin
            // Write new data into the slot selected by the current write pointer.
            fifo[b_wptr[ADD_SIZE-1:0]] <= data_in;
        end
    end

//    always @(posedge rd_clk) begin
//        if (rd_en && !empty) begin
//            data_out <= fifo[b_rptr[PTR_WIDTH-1:0]];
//        end
//    end
    // The current design uses a combinational read path from the selected slot.
    assign data_out = fifo[b_rptr[ADD_SIZE-1:0]];

endmodule
