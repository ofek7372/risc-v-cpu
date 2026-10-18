`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2026 14:41:43
// Design Name: 
// Module Name: RV32I_ALUsrc
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


module RV32I_ALUsrc #(parameter  WIDTH=32 )(
    input [2:0] EX_ALUsrc,
    input [WIDTH-1:0] EX_IMM,EX_PC,EX_R_B,EX_R_A,
    output reg [WIDTH-1:0] A,B
    

    );
    localparam REGop =3'b000;
    localparam IMMop =3'b001;
    localparam LUI   =3'b010;
    localparam AUIPC =3'b011;
    localparam LINKop   =3'b100;
    
    always @(*)
        begin
            case(EX_ALUsrc)
                REGop   :begin A=EX_R_A; B=EX_R_B; end
                IMMop   :begin A=EX_R_A; B=EX_IMM; end
                LUI     :begin A='b0; B=EX_IMM; end
                AUIPC   :begin A=EX_PC; B=EX_IMM; end
                LINKop  :begin A=EX_PC; B='d4; end
                default: begin A='b0; B='b0; end
            endcase
            end
endmodule
