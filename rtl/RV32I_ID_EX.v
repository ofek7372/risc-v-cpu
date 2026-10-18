`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:50:14
// Design Name: 
// Module Name: RV32I_ID_EX
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

module RV32I_ID_EX #(parameter WIDTH=32)(
    input clk,EN,nRST,FLUSH,
    input [WIDTH-1:0] ID_R_B, ID_R_A, ID_IMM,ID_PC,
    input [2:0] ID_ALUsrc,
    input [3:0] ID_ALUctrl,
    input [1:0] ID_jop,
    input ID_bop,
    input [4:0] ID_RS1,ID_RS2,
    input [2:0] ID_funct3,
    input ID_MEMrd,
    input ID_MEMwr,
    input ID_MEMtoREG,
    input [4:0] ID_RD,
    input ID_REGwr,
 
    output reg [WIDTH-1:0] EX_R_B, EX_R_A, EX_IMM, EX_PC,
    output reg [2:0] EX_ALUsrc,
    output reg [3:0] EX_ALUctrl,
    output reg [1:0] EX_jop,
    output reg EX_bop,
    output reg [4:0] EX_RS1, EX_RS2,
    output reg [2:0] EX_funct3,
    output reg EX_MEMrd,
    output reg EX_MEMwr,
    output reg EX_MEMtoREG,
    output reg [4:0] EX_RD,
    output reg EX_REGwr
    );
 
    always @(posedge clk) begin
        if (nRST == 1'b0) begin
            EX_R_B <= 'b0;
            EX_R_A <= 'b0;
            EX_IMM <= 'b0;
            EX_PC <= 'b0;
            EX_ALUsrc <= 'b0;
            EX_ALUctrl <= 'b0;
            EX_jop <= 'b0;
            EX_bop <= 'b0;
            EX_RS1 <= 'b0;
            EX_RS2 <= 'b0;
            EX_funct3 <= 'b0;
            EX_MEMrd <= 'b0;
            EX_MEMwr <= 'b0;
            EX_MEMtoREG <= 'b0;
            EX_RD <= 'b0;
            EX_REGwr <= 'b0;
        end
        else if (FLUSH == 1'b1) begin
            EX_R_B <= 'b0;
            EX_R_A <= 'b0;
            EX_IMM <= 'b0;
            EX_PC <= 'b0;
            EX_ALUsrc <= 'b0;
            EX_ALUctrl <= 'b0;
            EX_jop <= 'b0;
            EX_bop <= 'b0;
            EX_RS1 <= 'b0;
            EX_RS2 <= 'b0;
            EX_funct3 <= 'b0;
            EX_MEMrd <= 'b0;
            EX_MEMwr <= 'b0;
            EX_MEMtoREG <= 'b0;
            EX_RD <= 'b0;
            EX_REGwr <= 'b0;
        end
        else if (EN == 1'b1) begin
            EX_R_B <= ID_R_B;
            EX_R_A <= ID_R_A;
            EX_IMM <= ID_IMM;
            EX_PC <= ID_PC;
            EX_ALUsrc <= ID_ALUsrc;
            EX_ALUctrl <= ID_ALUctrl;
            EX_jop <= ID_jop;
            EX_bop <= ID_bop;
            EX_RS1 <= ID_RS1;
            EX_RS2 <= ID_RS2;
            EX_funct3 <= ID_funct3;
            EX_MEMrd <= ID_MEMrd;
            EX_MEMwr <= ID_MEMwr;
            EX_MEMtoREG <= ID_MEMtoREG;
            EX_RD <= ID_RD;
            EX_REGwr <= ID_REGwr;
        end
    end
endmodule