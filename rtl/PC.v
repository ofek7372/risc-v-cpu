`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 15:58:59
// Design Name: 
// Module Name: PC
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


module PC
#(parameter WIDTH=5)
 
(input EN, nRST, clk, 
 input [WIDTH-1:0] D,
 output reg [WIDTH-1:0] Q);
 always @(posedge clk)
  begin 
   if (nRST == 1'b0) Q<= 'b0;
   else if (EN == 1'b0) Q<= Q;
   else Q <=D;
   end
   endmodule 