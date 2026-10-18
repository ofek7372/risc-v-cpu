`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:49:34
// Design Name: 
// Module Name: RV32I_IF_ID
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


module RV32I_IF_ID #(parameter WIDTH=32)(
    input clk,
    input EN,
    input nRST,
    input FLUSH,
    input [WIDTH-1:0] IF_PC,
    input [WIDTH-1:0] IF_inst,
    output reg [WIDTH-1:0] ID_PC,ID_inst 
    );
    
    always @(posedge clk)
        if (nRST == 'b0)
            {ID_inst,ID_PC} <= 'b0;
        else if (FLUSH=='b1)
            {ID_inst,ID_PC} <= 'b0;
        else if (EN == 1'b1)
            {ID_inst,ID_PC} <= {IF_inst,IF_PC};
        else 
         {ID_inst,ID_PC} <= {ID_inst,ID_PC};
       
endmodule
