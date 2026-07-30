`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 12:18:09
// Design Name: 
// Module Name: bubble_insertion_unit
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


module bubble_insertion_unit
    #(parameter rs_lines=5)
    (
    input [1:0] bop,
    input [rs_lines-1:0] RS1,RS2,ID_EX_RD,EX_MEM_RD, 
    input EX_MEM_REGwr, EX_MEM_MEMrd, ID_EX_REGwr,ID_EX_MEMrd,
    output stall
    );
    wire c1,c2;
    localparam bne=2'b10;
    localparam beq=2'b01;
    assign c1 = (
                (ID_EX_MEMrd | ((bop == bne)| (bop==beq))) 
                 &ID_EX_REGwr 
                 &((RS1==ID_EX_RD)|(RS2==ID_EX_RD))
                 );
  assign c2 = (
                EX_MEM_MEMrd 
              & EX_MEM_REGwr 
              &((bop==bne)|(bop==beq)) 
              & ((RS1 == EX_MEM_RD)|(RS2 == EX_MEM_RD))
              );
   assign stall = c1 | c2;
   
endmodule
