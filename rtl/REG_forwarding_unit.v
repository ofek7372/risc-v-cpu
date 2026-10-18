`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 10:33:34
// Design Name: 
// Module Name: REG_forwarding_unit
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


module REG_forwarding_unit #(parameter word=32)
    (
    input [4:0] RS1, RS2, WB_RD,
    input WB_REGwr,
    input [word-1:0] r_a, r_b, WB_WBdata,
    output reg [word-1:0] REG_A,REG_B    
    );
    
    always @(*)
        begin
            if (WB_REGwr & (RS1==WB_RD) & (RS1!= 'b0)) REG_A = WB_WBdata;
            else REG_A = r_a;
            if (WB_REGwr & (RS2==WB_RD) & (RS2!= 'b0)) REG_B = WB_WBdata;
            else REG_B = r_b;
            end
endmodule
