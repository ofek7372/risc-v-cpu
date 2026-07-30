`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 14:27:53
// Design Name: 
// Module Name: Branch_evaluation_unit
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


module Branch_evaluation_unit
    #(parameter word=32)
    (
    input [1:0] bop,
    input [word-1:0] comp_a,comp_b,
    output branch
    );
    localparam bne =2'b10;
    localparam beq =2'b01;
    
    
    wire NEQ;
    assign NEQ = (comp_a != comp_b);
    
    assign branch = (NEQ & (bop==bne)) | ((~NEQ)&(bop==beq));
    
    
    
endmodule
