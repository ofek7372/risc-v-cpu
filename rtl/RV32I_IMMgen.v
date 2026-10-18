`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 16:37:20
// Design Name: 
// Module Name: RV32I_IMMgen
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


module RV32I_IMMgen(input [2:0] IMMsrc,
                  input [31:7] imm_lines,
                  output reg [31:0] imm
                  );
                  localparam  I_type=3'b000;
                  localparam  B_type=3'b001;
                  localparam  S_type=3'b011;
                  localparam  U_type=3'b010;
                  localparam  J_type=3'b100;
                  
                  always @(*)
                    begin
                        case(IMMsrc)
                            I_type: imm= {{20{imm_lines[31]}},imm_lines[31:20]};
                            S_type: imm= {{20{imm_lines[31]}},imm_lines[31:25],imm_lines[11:7]};
                            U_type: imm= {imm_lines[31:12],{12{1'b0}}};
                            B_type: imm= {{19{imm_lines[31]}},imm_lines[31],imm_lines[7],imm_lines[30:25],imm_lines[11:8],1'b0};
                            J_type: imm ={{11{imm_lines[31]}},imm_lines[31],imm_lines[19:12],imm_lines[20],imm_lines[30:21],1'b0};
                            default: imm= 32'b0;
                        endcase
                        end
                          
endmodule