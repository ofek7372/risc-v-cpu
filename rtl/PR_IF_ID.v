`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 10:54:17
// Design Name: 
// Module Name: PR_IF_ID
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


module PR_IF_ID #(parameter PC_WIDTH=7, parameter INST_WIDTH=32)(
    input [PC_WIDTH-1:0] PC_in,
    input [INST_WIDTH-1:0] inst_in,
    input nRST,EN,clk,    
    output reg [PC_WIDTH-1:0] PC_out,
    output reg [INST_WIDTH-1:0] inst_out
    );
    
    always @(posedge clk)
        begin
            if(~nRST)
                begin 
                    PC_out<='b0;
                    inst_out<='b0;
                    end
            else if (EN)
                begin
                    PC_out<=PC_in;
                    inst_out<=inst_in;
                end
        end 
endmodule
