`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 11:10:18
// Design Name: 
// Module Name: Branch_forwarding_unit
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


module Branch_forwarding_unit
#(parameter word=32, parameter rs_lines=5)
(
    input [word-1:0] REG_A, REG_B,ALUresult,WBdata,
    input [rs_lines-1:0] RS1,RS2,EX_MEM_RD,MEM_WB_RD,
    input EX_MEM_REGwr,MEM_WB_REGwr,EX_MEM_MEMrd,
    output reg [word-1:0] comp_a,comp_b
    );
 
always @(*)
    begin 
        //a channel 
        if (EX_MEM_REGwr &(~EX_MEM_MEMrd) &(RS1==EX_MEM_RD) & (RS1!='b0)) comp_a = ALUresult;
        else if (MEM_WB_REGwr & (RS1== MEM_WB_RD) & (RS1!='b0)) comp_a=WBdata;
        else comp_a = REG_A;
        
         if (EX_MEM_REGwr &(~EX_MEM_MEMrd)&(RS2==EX_MEM_RD)& (RS2!='b0)) comp_b = ALUresult;
        else if (MEM_WB_REGwr & (RS2== MEM_WB_RD)& (RS2!='b0)) comp_b=WBdata;
        else comp_b = REG_B;
   end
  
endmodule
