`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 14:20:41
// Design Name: 
// Module Name: PR_ID_EX
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


module PR_ID_EX
    #(parameter imm_width=32,parameter rs_lines=5,parameter word=32)
    (
    input clk,
    input MEMtoREG_in,ALUsrc_in,MEMrd_in,MEMwr_in,REGwr_in,
    input [1:0] ALUop_in,
    input [imm_width-1:0] imm_in,
    input [word-1:0] R_A_in,R_B_in,
    input [rs_lines-1:0] RS1_in,RS2_in,RD_in,
    input [6:0] funct7_in,
    input [2:0] funct3_in,
    output reg MEMtoREG_out,ALUsrc_out,MEMrd_out,MEMwr_out,REGwr_out,
    output reg [1:0] ALUop_out,
    output reg [imm_width-1:0] imm_out,
    output reg  [word-1:0] R_A_out,R_B_out,
    output reg  [rs_lines-1:0] RS1_out,RS2_out,RD_out,
    output reg  [6:0] funct7_out,
    output reg [2:0] funct3_out
    );

always @(posedge clk)
    begin
        MEMtoREG_out <= MEMtoREG_in;
        ALUsrc_out   <= ALUsrc_in;
        MEMrd_out    <= MEMrd_in;
        MEMwr_out    <= MEMwr_in;
        REGwr_out    <= REGwr_in;
        ALUop_out   <=ALUop_in;
        imm_out     <=imm_in;
        R_A_out     <=R_A_in;
        R_B_out     <=R_B_in;
        RS1_out     <=RS1_in;
        RS2_out     <=RS2_in;
        RD_out      <=RD_in;
        funct7_out  <=funct7_in;
        funct3_out  <=funct3_in;
end
endmodule

