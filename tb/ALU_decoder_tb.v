`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 12:11:47
// Design Name: 
// Module Name: ALU_decoder_tb
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


module ALU_decoder_tb;
localparam N=14;

reg [6:0] funct7;
reg [2:0] funct3;
reg [1:0] ALUop;
wire [2:0]ALU_ctrl;

SC_alu_decoder DUT(.funct7(funct7), .funct3(funct3), .ALUop(ALUop), .ALU_ctrl(ALU_ctrl));

reg [6:0] tv_funct7 [N-1:0];
reg [2:0] tv_funct3 [N-1:0];
reg [1:0] tv_ALUop  [N-1:0];
reg [2:0] exp_ALU_ctrl [N-1:0];

integer pass;integer fail; integer t;

task automatic ALU_decoder(input [6:0] in_7, 
                           input [2:0] in_3 ,
                           input [1:0] in_op ,
                           input [2:0] in_exp_ctrl);
                           begin
                           
                           funct7=in_7;funct3=in_3;ALUop=in_op;
                           #10
                           
                           if (in_exp_ctrl !== ALU_ctrl)
                            begin 
                                $error ("T: %0d, FAILD",t);
                                fail=fail+1;
                            end
                            
                            else 
                                begin
                                    $display("T:%0d PASSED",t);
                                        pass=pass+1;
                                end
                           end
                           endtask
                           
                           initial 
                            begin
                                fail=0;
                                pass=0;
                                t=0;
                                
                               // R-type (ALUop=00): all 8 operations
tv_funct7[0]=7'b0000000; tv_funct3[0]=3'b000; tv_ALUop[0]=2'b00; exp_ALU_ctrl[0]=3'b000; // ADD
tv_funct7[1]=7'b0100000; tv_funct3[1]=3'b000; tv_ALUop[1]=2'b00; exp_ALU_ctrl[1]=3'b001; // SUB
tv_funct7[2]=7'b0000000; tv_funct3[2]=3'b111; tv_ALUop[2]=2'b00; exp_ALU_ctrl[2]=3'b010; // AND
tv_funct7[3]=7'b0000000; tv_funct3[3]=3'b110; tv_ALUop[3]=2'b00; exp_ALU_ctrl[3]=3'b011; // OR
tv_funct7[4]=7'b0000000; tv_funct3[4]=3'b100; tv_ALUop[4]=2'b00; exp_ALU_ctrl[4]=3'b100; // XOR
tv_funct7[5]=7'b0000000; tv_funct3[5]=3'b010; tv_ALUop[5]=2'b00; exp_ALU_ctrl[5]=3'b101; // SLT
tv_funct7[6]=7'b0000000; tv_funct3[6]=3'b001; tv_ALUop[6]=2'b00; exp_ALU_ctrl[6]=3'b110; // SLL
tv_funct7[7]=7'b0000000; tv_funct3[7]=3'b101; tv_ALUop[7]=2'b00; exp_ALU_ctrl[7]=3'b111; // SRL
// I-type (ALUop=01): spot check 3 operations
tv_funct7[8]=7'b0000000;  tv_funct3[8]=3'b000;  tv_ALUop[8]=2'b01;  exp_ALU_ctrl[8]=3'b000;  // ADDI
tv_funct7[9]=7'b0000000;  tv_funct3[9]=3'b111;  tv_ALUop[9]=2'b01;  exp_ALU_ctrl[9]=3'b010;  // ANDI
tv_funct7[10]=7'b0000000; tv_funct3[10]=3'b001; tv_ALUop[10]=2'b01; exp_ALU_ctrl[10]=3'b110; // SLLI
// LW/SW (ALUop=10)
tv_funct7[11]=7'b0000000; tv_funct3[11]=3'b010; tv_ALUop[11]=2'b10; exp_ALU_ctrl[11]=3'b000; // ADD
// Branch (ALUop=11)
tv_funct7[12]=7'b0000000; tv_funct3[12]=3'b000; tv_ALUop[12]=2'b11; exp_ALU_ctrl[12]=3'b001; // SUB
// Default: invalid funct3 on R-type
tv_funct7[13]=7'b0000000; tv_funct3[13]=3'b011; tv_ALUop[13]=2'b00; exp_ALU_ctrl[13]=3'b000; // default

for (t=0;t<14;t=t+1)
    ALU_decoder(tv_funct7[t],tv_funct3[t], tv_ALUop[t], exp_ALU_ctrl[t]);
    $display("PASS:%0d, FAIL:%0d",pass,fail);
    $finish;
    end
    

endmodule

