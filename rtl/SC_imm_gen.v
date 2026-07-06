`timescale 1ns / 1ps
//i tpye Filds [31:20] | code:  00 | 12 bits
//s type filds [31:25][11:7] | code: 11 | 12 bits 
//u type fildes [31:12] | code:  10 | 20 bits
module SC_imm_gen(input [1:0] IMMsrc,
                  input [31:7] imm_lines,
                  output reg [31:0] imm
                  );
                  localparam  I_type=2'b00;
                  localparam  B_type=2'b01;
                  localparam  S_type=2'b11;
                  localparam  U_type=2'b10;
                  
                  always @(*)
                    begin
                        case(IMMsrc)
                            I_type: imm= {{20{imm_lines[31]}},imm_lines[31:20]};
                            S_type: imm= {{20{imm_lines[31]}},imm_lines[31:25],imm_lines[11:7]};
                            U_type: imm= {imm_lines[31:12],{12{1'b0}}};
                            B_type: imm= {{19{imm_lines[31]}},imm_lines[31],imm_lines[7],imm_lines[30:25],imm_lines[11:8],1'b0};
                            default: imm= 32'b0;
                        endcase
                        end
                          
endmodule
