`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:51:19
// Design Name: 
// Module Name: RV32I_MEM_WB
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


module RV32I_MEM_WB #(parameter WIDTH=32)(
    input clk,EN,nRST,FLUSH,
    input [WIDTH-1:0] MEM_WBdata,
    input [4:0] MEM_RD,
    input MEM_REGwr,
    output reg [WIDTH-1:0] WB_WBdata,
    output reg [4:0] WB_RD,
    output reg WB_REGwr
    );
    
    always @(posedge clk)
       begin 
        if (~nRST)
            begin
            WB_WBdata <= 'b0;
            WB_RD <= 'b0;
            WB_REGwr <=1'b0;
            end
        else if (FLUSH)
            begin
            WB_WBdata <= 'b0;
            WB_RD <= 'b0;
            WB_REGwr <=1'b0;
            end
        else if (EN)
            begin
            WB_WBdata <= MEM_WBdata;
            WB_RD <= MEM_RD;
            WB_REGwr <= MEM_REGwr;
            end
       end 
endmodule
