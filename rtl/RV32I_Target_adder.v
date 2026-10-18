`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:52:16
// Design Name: 
// Module Name: RV32I_Target_adder
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


module RV32I_Target_adder #(parameter WIDTH=32)(
    input [1:0] EX_jop,
    input [WIDTH-1:0] EX_PC,EX_IMM,A_FWD,
    output [WIDTH-1:0] target
    );
    assign target = (EX_jop != 2'b10) ? EX_PC+EX_IMM : ((A_FWD+EX_IMM)&(~32'b1));
endmodule
