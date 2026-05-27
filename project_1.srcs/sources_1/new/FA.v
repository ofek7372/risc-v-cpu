`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2026 18:38:52
// Design Name: 
// Module Name: FA
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


module FA
//parameter befor input output statment 
#(parameter width=4)(
input [width-1:0]a, b,
input Cin,
output [width-1:0] s, 
output Cout);
//behaviour
assign {Cout, s}= a + b + Cin;

endmodule
