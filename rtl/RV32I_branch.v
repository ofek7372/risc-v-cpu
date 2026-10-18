`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:56:53
// Design Name: 
// Module Name: RV32I_branch
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


module RV32I_branch #(parameter WIDTH=32)(
    input bop,zero,
    input [2:0]EX_funct3,
    input EX_ALUresult,
    output reg taken

    );
    localparam BEQ = 3'b000;
    localparam BNE = 3'b001;
    localparam BLT = 3'b100;
    localparam BGE = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;
    
    always@(*)
        begin
            if(bop)
                case(EX_funct3)
                    BEQ: taken= zero;
                    BNE: taken= ~zero;
                    BLT: taken= (EX_ALUresult==1'b1);
                    BGE: taken= (EX_ALUresult==1'b0);
                    BLTU: taken=(EX_ALUresult==1'b1);
                    BGEU: taken=(EX_ALUresult==1'b0);
                    default: taken = 1'b0;
                    endcase
            else
                taken=1'b0;
            end
                    
endmodule
