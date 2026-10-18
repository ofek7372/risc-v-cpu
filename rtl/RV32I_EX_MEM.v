`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:50:53
// Design Name: 
// Module Name: RV32I_EX_MEM
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


module RV32I_EX_MEM #(parameter WIDTH=32)(
    input clk,nRST,EN,FLUSH,
    input [WIDTH-1:0] EX_B_FWD,EX_ALUresult,
    input [2:0] EX_funct3,
    input EX_MEMrd,EX_MEMwr,EX_MEMtoREG,
    input [4:0] EX_RD,
    input EX_REGwr,
 
    output reg [WIDTH-1:0] MEM_B_FWD, MEM_ALUresult,
    output reg [2:0] MEM_funct3,
    output reg MEM_MEMrd, MEM_MEMwr, MEM_MEMtoREG,
    output reg [4:0] MEM_RD,
    output reg MEM_REGwr
    );
 
    always @(posedge clk) begin
        if (nRST == 1'b0) begin
            MEM_B_FWD <= 'b0;
            MEM_ALUresult <= 'b0;
            MEM_funct3 <= 'b0;
            MEM_MEMrd <= 'b0;
            MEM_MEMwr <= 'b0;
            MEM_MEMtoREG <= 'b0;
            MEM_RD <= 'b0;
            MEM_REGwr <= 'b0;
        end
        else if (FLUSH == 1'b1) begin
            MEM_B_FWD <= 'b0;
            MEM_ALUresult <= 'b0;
            MEM_funct3 <= 'b0;
            MEM_MEMrd <= 'b0;
            MEM_MEMwr <= 'b0;
            MEM_MEMtoREG <= 'b0;
            MEM_RD <= 'b0;
            MEM_REGwr <= 'b0;
        end
        else if (EN == 1'b1) begin
            MEM_B_FWD <= EX_B_FWD;
            MEM_ALUresult <= EX_ALUresult;
            MEM_funct3 <= EX_funct3;
            MEM_MEMrd <= EX_MEMrd;
            MEM_MEMwr <= EX_MEMwr;
            MEM_MEMtoREG <= EX_MEMtoREG;
            MEM_RD <= EX_RD;
            MEM_REGwr <= EX_REGwr;
        end
    end
endmodule