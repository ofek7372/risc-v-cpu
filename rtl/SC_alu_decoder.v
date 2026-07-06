`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 14:25:16
// Design Name: 
// Module Name: SC_alu_decoder
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


module SC_alu_decoder
    (
    input [6:0] funct7,
    input [2:0] funct3,
    input [1:0] ALUop,
    output reg [2:0] ALU_ctrl
    );
    
    always @(*)
       begin
       ALU_ctrl= 3'b000;
        case (ALUop)
            2'b00:begin
                case(funct3)
                    3'b000:ALU_ctrl = (funct7 == 7'b0) ? 3'b000 : 3'b001 ; //add or sub 
                    3'b111:ALU_ctrl =  3'b010; //AND
                    3'b110:ALU_ctrl =  3'b011; //OR
                    3'b100:ALU_ctrl =  3'b100; //XOR
                    3'b010:ALU_ctrl =  3'b101; //SLT
                    3'b001:ALU_ctrl =  3'b110; //SLL
                    3'b101:ALU_ctrl =  3'b111; //SRL
                    endcase
                    end
                    
                    
            2'b01: begin
                   case(funct3)
                    3'b000:ALU_ctrl =  3'b000; //add  
                    3'b111:ALU_ctrl =  3'b010; //AND
                    3'b110:ALU_ctrl =  3'b011; //OR
                    3'b100:ALU_ctrl =  3'b100; //XOR
                    3'b010:ALU_ctrl =  3'b101; //SLT
                    3'b001:ALU_ctrl =  3'b110; //SLL
                    3'b101:ALU_ctrl =  3'b111; //SRL
                    endcase
                    end 
            2'b10: ALU_ctrl = 3'b000;
            2'b11: ALU_ctrl = 3'b001; 
            endcase
            end
endmodule
