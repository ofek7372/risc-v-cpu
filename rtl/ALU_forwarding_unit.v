`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 16:36:59
// Design Name: 
// Module Name: ALU_forwarding_unit
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


module ALU_forwarding_unit
#(parameter rs_lines=5,parameter word=32)
(
    input [rs_lines-1:0] ID_EX_RS1, ID_EX_RS2, EX_MEM_RD, MEM_WB_RD,
    input [word-1:0] EX_MEM_ALUresult, MEM_WB_WBdata,ID_EX_R_A,ID_EX_R_B,
    input EX_MEM_REGwr, MEM_WB_REGwr,
    output reg [word-1:0] ALU_A,ALU_B
    
    );
    
always @(*)
    begin
    //A channel
    if (EX_MEM_REGwr & (ID_EX_RS1 == EX_MEM_RD) & (ID_EX_RS1 != 'b0)) ALU_A = EX_MEM_ALUresult;
    else if (MEM_WB_REGwr & (ID_EX_RS1 == MEM_WB_RD)& (ID_EX_RS1!='b0)) ALU_A = MEM_WB_WBdata;
    else ALU_A = ID_EX_R_A;
    
    //channel B
    if (EX_MEM_REGwr & (ID_EX_RS2 == EX_MEM_RD) & (ID_EX_RS2 != 'b0)) ALU_B = EX_MEM_ALUresult;
    else if (MEM_WB_REGwr & (ID_EX_RS2 == MEM_WB_RD) &(ID_EX_RS2 != 'b0)) ALU_B = MEM_WB_WBdata;
    else ALU_B = ID_EX_R_B;
    end
endmodule
