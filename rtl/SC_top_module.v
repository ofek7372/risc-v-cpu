`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 16:41:04
// Design Name: 
// Module Name: SC_top_module
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


module SC_top_module
    #(parameter word=32,inst_addr_width=7,data_addr_width=7)
    (
    input clk,
    input nRST,
    input EN
    );
    
    //PC wires
    wire  [inst_addr_width-1:0] PC_out;
    wire  [inst_addr_width-1:0] PC_in; //PC_in = ((Bop=10)&Z)|| (Bop=01)&(~Z) ? ((imm*2)+PC_out) : PC_out+4
    
    //inst mem gets pc_out, output contect to inst
    wire  [word-1:0]inst; 
    //main decoder gets inst
    wire [1:0] ALUop,IMMsrc,Bop;
    wire ALUsrc,REGwr,MEMwr,MEMrd,MEMtoREG;
    //imm file gets imm filds and IMMsrc output to imm
    wire [word-1:0] imm;
    //reg file gets RS1 RS2 RD from instruction, gets REGwr from decoder, gets reg data in
    wire [word-1:0]R_B;
    wire [word-1:0]R_A;
    wire [word-1:0] reg_data_in; // reg_data_in = (MEMtoREG) ? mem_data_out : alu_result
    wire [4:0] R_D;
    wire [4:0] RS1;
    wire [4:0] RS2;
    
    wire [2:0] ALU_ctrl;
    wire [word-1:0] ALU_result; 
    wire cout_borrow, Z, negative;
    
    wire [word-1:0] mem_data_out;
    wire PCsrc;
    //PC
    
    PC #(.WIDTH(inst_addr_width)) pc (.clk(clk),.nRST(nRST),.EN(EN),.D(PC_in), .Q(PC_out));
    assign PC_in = (PCsrc) ? (imm[inst_addr_width-1:0]+PC_out) : (PC_out+4);
    assign PCsrc=((Bop == 2'b10)&&Z) || ((Bop== 2'b01) && (~Z));
    
    
    //instruction mem
    SC_instruction_mem #(.INST_WIDTH(word), .ADDR_WIDTH(inst_addr_width)) inst_mem (.Addr(PC_out),.inst(inst));
    
    
    //main decoder
    
    SC_main_decoder main_decoder (.oppcode(inst[6:0]), 
                                  .funct3(inst[14:12]), 
                                  .ALUop(ALUop), 
                                  .IMMsrc(IMMsrc), 
                                  .Bop(Bop), 
                                  .ALUsrc(ALUsrc),
                                  .REGwr(REGwr),
                                  .MEMwr(MEMwr),
                                  .MEMrd(MEMrd),
                                  .MEMtoREG(MEMtoREG)
                                  );
  // IMM gen
  SC_imm_gen immgen (.IMMsrc(IMMsrc),
                     .imm_lines(inst[31:7]),
                     .imm(imm));
                     
 //REG file
  SC_REG_FILE reg_file (.RS1(RS1), 
                        .RS2(RS2), 
                        .RD(R_D), 
                        .REGwr(REGwr) ,
                        .clk(clk), 
                        .data_in(reg_data_in), 
                        .R_A(R_A), 
                        .R_B(R_B)
                        );
  assign RS1=inst[19:15]; 
  assign RS2= inst[24:20];                     
  assign reg_data_in = (MEMtoREG)? mem_data_out : ALU_result ;
  assign R_D=inst[11:7];
  //ALU decoder
  SC_alu_decoder alu_decoder (.funct7(inst[31:25]),
                              .funct3(inst[14:12]),
                              .ALUop(ALUop),
                              .ALU_ctrl(ALU_ctrl)
                              );
                              
  //ALU
   ALU_v1 #(.WIDTH(word)) alu (.a(R_A), 
                               .b((ALUsrc)?imm:R_B),
                               .alu_ctrl(ALU_ctrl),
                               .Y(ALU_result),
                               .cout_borrow(cout_borrow),
                               .zero(Z),
                               .negative(negative)  
   ); 
   
 //  data_mem
 SC_data_mem #(.WIDTH(word), .ADDR_lines(data_addr_width)) data_mem (.data_in(R_B),
                                                                .data_out(mem_data_out),
                                                                .clk(clk),
                                                                .MEMrd(MEMrd),
                                                                .MEMwr(MEMwr),
                                                                .addr(ALU_result[data_addr_width-1:0])
                                                                );
                                                                                          
endmodule
