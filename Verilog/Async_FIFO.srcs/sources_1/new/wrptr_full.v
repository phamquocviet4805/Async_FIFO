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


module wrptr_full #(parameter PTR_WIDTH = 4)(
    input wr_clk, wr_rst_n, wr_en,
    input [PTR_WIDTH:0] g_rptr_sync,    
    output reg full,
    output reg [PTR_WIDTH:0] g_wptr, b_wptr
    );
    
    reg [PTR_WIDTH:0] b_wptr_next;
    reg [PTR_WIDTH:0] g_wptr_next;
    
    reg wrap_around;
    wire wr_full;
    
    assign b_wptr_next = b_wptr+(wr_en & !full);
    assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
  
    always@(posedge wr_clk or negedge wr_rst_n) begin
      if(!wr_rst_n) begin
        b_wptr <= 0; 
        g_wptr <= 0;
      end
      else begin
        b_wptr <= b_wptr_next; 
        g_wptr <= g_wptr_next; 
      end
    end
  
  
    always@(posedge wr_clk or negedge wr_rst_n) begin
      if(!wr_rst_n) full <= 0;
      else        full <= wr_full;
    end

    assign wr_full = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH], g_rptr_sync[PTR_WIDTH-1:0]});   
    
endmodule
