`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 16:09:10
// Design Name: 
// Module Name: PR_MEM_WB
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


module PR_MEM_WB
#(parameter word=32, parameter rs_lines=5)
(
    input clk,
    input REGwr_in,
    input [word-1:0] WBdata_in,
    input [rs_lines-1:0] RD_in,
    output reg REGwr_out,
    output reg [word-1:0] WBdata_out,
    output reg [rs_lines-1:0] RD_out

    );
    
    always @(posedge clk)
        begin
            REGwr_out <=REGwr_in;
            WBdata_out <=WBdata_in;
            RD_out<=RD_in;
            end
            
endmodule
