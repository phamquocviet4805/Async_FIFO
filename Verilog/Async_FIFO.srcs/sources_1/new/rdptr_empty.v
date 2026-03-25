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
    input rd_clk, rd_rst_n, rd_en,
    input [PTR_WIDTH:0] g_wptr_sync,    
    output reg empty,
    output reg [PTR_WIDTH:0] g_rptr, b_rptr
    );

    reg [PTR_WIDTH:0] b_rptr_next;
    reg [PTR_WIDTH:0] g_rptr_next;

    assign b_rptr_next = b_rptr+(rd_en & !empty);
    assign g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
    assign empty = (g_wptr_sync == g_rptr_next);
  
    always@(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
        end
        else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end
  
    always@(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n) 
            empty <= 1;
        else        
            empty <= empty;
    end

endmodule
