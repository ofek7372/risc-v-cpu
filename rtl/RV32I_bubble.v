`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:56:19
// Design Name: 
// Module Name: RV32I_bubble
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


module RV32I_bubble (
    input [4:0] ID_RS1,ID_RS2,EX_RD,
    input EX_MEMrd,EX_REGwr,EX_MEMtoREG,
    output reg stall
    );
    wire load;
    assign load = EX_MEMrd & EX_REGwr & EX_MEMtoREG;
    always @(*)
    if ((((ID_RS1 != 'b0)&(ID_RS1==EX_RD)) || ((ID_RS2 != 1'b0)&(ID_RS2== EX_RD)))& load)
        stall=1'b1;
    else
        stall='b0;
    
endmodule
