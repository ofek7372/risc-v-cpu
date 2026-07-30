`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 14:44:17
// Design Name: 
// Module Name: PR_EX_MEM
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


module PR_EX_MEM
#(parameter word=32,parameter rs_lines=5)
(
    input clk,
    input REGwr_in,MEMwr_in,MEMrd_in,MEMtoREG_in,
    input [word-1:0] ALUresult_in,
    input [word-1:0] R_B_in,
    input [rs_lines-1:0] RD_in,
    output reg REGwr_out, MEMwr_out,MEMrd_out,MEMtoREG_out,
    output reg [word-1:0] ALUresult_out, 
    output reg [word-1:0] R_B_out,
    output reg [rs_lines-1:0] RD_out 
    );
    
    always @(posedge clk)
        begin
        ALUresult_out <= ALUresult_in;
        R_B_out <=  R_B_in;
        RD_out<= RD_in;
        REGwr_out<= REGwr_in;
        MEMwr_out<= MEMwr_in;
        MEMrd_out<= MEMrd_in;
        MEMtoREG_out<=  MEMtoREG_in;
        end
endmodule
