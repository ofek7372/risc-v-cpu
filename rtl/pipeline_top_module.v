`timescale 1ns / 1ps

module pipeline_top_module
 #(parameter word=32,inst_addr_width=7,data_addr_width=7)
    (
    input clk,
    input nRST,
    input EN
    );
    //IF stage
    wire [inst_addr_width-1:0] pc_in, pc_out;
    wire [word-1:0] inst;
    wire PCsrc,IF_FLUSH,stall;
    wire [inst_addr_width-1:0] IF_ID_PC;
    wire [word-1:0] IF_ID_inst;
    //
    //ID stage
    wire [4:0]ID_RS1,ID_RS2;
    wire [1:0] ID_ALUop, ID_IMMsrc,ID_Bop;
    wire ID_ALUsrc,ID_REGwr,ID_MEMwr,ID_MEMrd,ID_MEMtoREG;
    wire [word-1:0] ID_imm;
    wire [word-1:0] ID_R_A_raw, ID_R_B_raw;
    wire [word-1:0] ID_R_A, ID_R_B;
    wire branch;
    wire [inst_addr_width-1:0] branch_target;
    wire [word-1:0]ID_comp_a,ID_comp_b;
    wire [2:0] ID_funct3;
    wire [6:0] ID_funct7;
  
    //
    //EX stage
    wire EX_MEMtoREG,EX_ALUsrc,EX_MEMrd,EX_MEMwr,EX_REGwr;
    wire [1:0] EX_ALUop;
    wire [word-1:0] EX_imm;
    wire [word-1:0] EX_R_A,EX_R_B;
    wire [4:0] EX_RS1,EX_RS2,EX_RD;
    wire [6:0] EX_funct7;
    wire [2:0] EX_funct3;
    wire [2:0] EX_ALU_ctrl;
    wire [word-1:0] EX_ALU_A,EX_ALU_B;
    wire [word-1:0] EX_ALU_result;
    wire EX_cout_borrow,EX_zero,EX_negative;
    //
    //MEM stage
    wire MEM_REGwr,MEM_MEMwr,MEM_MEMrd,MEM_MEMtoREG;
    wire [word-1:0] MEM_ALU_result;
    wire [word-1:0] MEM_R_B;
    wire [4:0] MEM_RD;
    wire [word-1:0] MEM_data_out;
    //
    //WB stage
    wire WB_REGwr;
    wire [word-1:0] WB_WBdata;
    wire [4:0] WB_RD;
    
    //IF stage
    PC #(.WIDTH(inst_addr_width)) pc (.EN(~stall), 
                                      .nRST(nRST), 
                                      .clk(clk), 
                                      .D(pc_in), 
                                      .Q(pc_out)
                                      );
    assign pc_in = (PCsrc) ? branch_target : (pc_out+4); //need to set PCsrc from  branch , and to set branch_target in the ID stage  
    assign PCsrc = branch &(~stall);
    
    assign branch_target = (ID_imm [inst_addr_width-1:0] + IF_ID_PC);
                                   
    SC_instruction_mem #(.ADDR_WIDTH(inst_addr_width), .INST_WIDTH(word)) inst_mem (.Addr(pc_out), 
                                                                                    .inst(inst)
                                                                                    );
                                                                                    
                                                                                    
                                                                                    
    PR_IF_ID #(.PC_WIDTH(inst_addr_width), .INST_WIDTH(word)) if_id (.PC_in(pc_out), 
                                                                     .inst_in(inst), 
                                                                     .nRST(IF_FLUSH), 
                                                                     .EN(~stall), 
                                                                     .clk(clk), 
                                                                     .PC_out(IF_ID_PC), 
                                                                     .inst_out(IF_ID_inst));
                                                                     
                                                                     assign IF_FLUSH = ~((branch &(~stall))|(~nRST)); //the register flush when branch and not stall is 0 or on a global reset 

    //ID stage
    assign ID_RS1 = IF_ID_inst[19:15];
    assign ID_RS2 = IF_ID_inst[24:20];
    assign ID_funct7 = IF_ID_inst[31:25];
    assign ID_funct3 = IF_ID_inst[14:12];
   
    SC_main_decoder main_decoder (.oppcode(IF_ID_inst[6:0]), 
                                  .funct3(ID_funct3), 
                                  .ALUop(ID_ALUop), 
                                  .IMMsrc(ID_IMMsrc), 
                                  .Bop(ID_Bop), 
                                  .ALUsrc(ID_ALUsrc), 
                                  .REGwr(ID_REGwr), 
                                  .MEMwr(ID_MEMwr), 
                                  .MEMrd(ID_MEMrd), 
                                  .MEMtoREG(ID_MEMtoREG)
                                  );
                                  
   
    SC_imm_gen immgen (.IMMsrc(ID_IMMsrc), 
                       .imm_lines(IF_ID_inst[31:7]), 
                       .imm(ID_imm));
    
    SC_REG_FILE #(.REG_WIDTH(word), .ADDR_LINES(5)) reg_file (.RS1(ID_RS1), 
                                                              .RS2(ID_RS2), 
                                                              .RD(WB_RD), 
                                                              .REGwr(nRST ? WB_REGwr : 1'b0 ), 
                                                              .clk(clk), 
                                                              .data_in(WB_WBdata), 
                                                              .R_A(ID_R_A_raw), 
                                                              .R_B(ID_R_B_raw)
                                                              );

    
    REG_forwarding_unit #(.word(word)) reg_fwd (.RS1(ID_RS1), 
                                                .RS2(ID_RS2), 
                                                .MEM_WB_RD(WB_RD), 
                                                .MEM_WB_REGwr(WB_REGwr), 
                                                .r_a(ID_R_A_raw), 
                                                .r_b(ID_R_B_raw), 
                                                .MEM_WB_WBdata(WB_WBdata), 
                                                .REG_A(ID_R_A), 
                                                .REG_B(ID_R_B)
                                                );
    
   
    Branch_forwarding_unit #(.word(word), .rs_lines(5)) branch_fwd (.REG_A(ID_R_A), 
                                                                    .REG_B(ID_R_B), 
                                                                    .ALUresult(MEM_ALU_result), 
                                                                    .WBdata(WB_WBdata), 
                                                                    .RS1(ID_RS1), 
                                                                    .RS2(ID_RS2), 
                                                                    .EX_MEM_RD(MEM_RD), 
                                                                    .MEM_WB_RD(WB_RD), 
                                                                    .EX_MEM_REGwr(MEM_REGwr), 
                                                                    .MEM_WB_REGwr(WB_REGwr), 
                                                                    .EX_MEM_MEMrd(MEM_MEMrd), 
                                                                    .comp_a(ID_comp_a), 
                                                                    .comp_b(ID_comp_b));
    
    Branch_evaluation_unit #(.word(word)) branch_eval (.bop(ID_Bop), 
                                                       .comp_a(ID_comp_a), 
                                                       .comp_b(ID_comp_b), 
                                                       .branch(branch));
    
    bubble_insertion_unit #(.rs_lines(5)) bubble (.bop(ID_Bop), 
                                                  .RS1(ID_RS1), 
                                                  .RS2(ID_RS2), 
                                                  .ID_EX_RD(EX_RD), 
                                                  .EX_MEM_RD(MEM_RD), 
                                                  .EX_MEM_REGwr(MEM_REGwr), 
                                                  .EX_MEM_MEMrd(MEM_MEMrd), 
                                                  .ID_EX_REGwr(EX_REGwr), 
                                                  .ID_EX_MEMrd(EX_MEMrd), 
                                                  .stall(stall)
                                                  );

    //ID/EX reg
   
    PR_ID_EX #(.imm_width(word), .rs_lines(5), .word(word)) id_ex (.clk(clk), 
                                                                   .MEMtoREG_in((stall |(~nRST)) ? 1'b0: ID_MEMtoREG), 
                                                                   .ALUsrc_in((stall |(~nRST))? 1'b0: ID_ALUsrc), 
                                                                   .MEMrd_in((stall |(~nRST))? 1'b0: ID_MEMrd), 
                                                                   .MEMwr_in((stall |(~nRST))? 1'b0: ID_MEMwr), 
                                                                   .REGwr_in((stall |(~nRST)) ? 1'b0: ID_REGwr), 
                                                                   .ALUop_in((stall |(~nRST)) ? 2'b0: ID_ALUop), 
                                                                   .imm_in(ID_imm), 
                                                                   .R_A_in(ID_R_A), 
                                                                   .R_B_in(ID_R_B), 
                                                                   .RS1_in(ID_RS1), 
                                                                   .RS2_in(ID_RS2), 
                                                                   .RD_in(IF_ID_inst[11:7]), 
                                                                   .funct7_in(ID_funct7), 
                                                                   .funct3_in(ID_funct3), 
                                                                   .MEMtoREG_out(EX_MEMtoREG), 
                                                                   .ALUsrc_out(EX_ALUsrc), 
                                                                   .MEMrd_out(EX_MEMrd), 
                                                                   .MEMwr_out(EX_MEMwr), 
                                                                   .REGwr_out(EX_REGwr), 
                                                                   .ALUop_out(EX_ALUop), 
                                                                   .imm_out(EX_imm), 
                                                                   .R_A_out(EX_R_A), 
                                                                   .R_B_out(EX_R_B), 
                                                                   .RS1_out(EX_RS1), 
                                                                   .RS2_out(EX_RS2), 
                                                                   .RD_out(EX_RD), 
                                                                   .funct7_out(EX_funct7), 
                                                                   .funct3_out(EX_funct3)
                                                                   );

    //EX stage
    ALU_forwarding_unit #(.rs_lines(5), .word(word)) alu_fwd (.ID_EX_RS1(EX_RS1), 
                                                              .ID_EX_RS2(EX_RS2), 
                                                              .EX_MEM_RD(MEM_RD), 
                                                              .MEM_WB_RD(WB_RD), 
                                                              .EX_MEM_ALUresult(MEM_ALU_result), 
                                                              .MEM_WB_WBdata(WB_WBdata), 
                                                              .ID_EX_R_A(EX_R_A), 
                                                              .ID_EX_R_B(EX_R_B), 
                                                              .EX_MEM_REGwr(MEM_REGwr), 
                                                              .MEM_WB_REGwr(WB_REGwr), 
                                                              .ALU_A(EX_ALU_A), 
                                                              .ALU_B(EX_ALU_B)
                                                              );
    
    SC_alu_decoder alu_decoder (.funct7(EX_funct7), 
                                .funct3(EX_funct3), 
                                .ALUop(EX_ALUop), 
                                .ALU_ctrl(EX_ALU_ctrl)
                                );
    
    ALU_v1 #(.WIDTH(word)) alu (.a(EX_ALU_A), 
                                .b(EX_ALUsrc ? EX_imm : EX_ALU_B), 
                                .alu_ctrl(EX_ALU_ctrl), 
                                .Y(EX_ALU_result), 
                                .cout_borrow(EX_cout_borrow), 
                                .zero(EX_zero), 
                                .negative(EX_negative));

    //EX/MEM reg
    PR_EX_MEM #(.word(word), .rs_lines(5)) ex_mem (.clk(clk), 
                                                   .REGwr_in( nRST ? EX_REGwr : 1'b0), 
                                                   .MEMwr_in(nRST ?EX_MEMwr : 1'b0), 
                                                   .MEMrd_in(nRST ? EX_MEMrd : 1'b0), 
                                                   .MEMtoREG_in( nRST ? EX_MEMtoREG: 1'b0), 
                                                   .ALUresult_in(EX_ALU_result), 
                                                   .R_B_in(EX_ALU_B), 
                                                   .RD_in(EX_RD), 
                                                   .REGwr_out(MEM_REGwr), 
                                                   .MEMwr_out(MEM_MEMwr), 
                                                   .MEMrd_out(MEM_MEMrd), 
                                                   .MEMtoREG_out(MEM_MEMtoREG), 
                                                   .ALUresult_out(MEM_ALU_result), 
                                                   .R_B_out(MEM_R_B), 
                                                   .RD_out(MEM_RD)
                                                   );

    //MEM stage
    SC_data_mem #(.WIDTH(word), .ADDR_lines(data_addr_width)) data_mem (.data_in(MEM_R_B), 
                                                                        .data_out(MEM_data_out), 
                                                                        .MEMrd(MEM_MEMrd), 
                                                                        .MEMwr(nRST ? MEM_MEMwr: 1'b0), 
                                                                        .clk(clk), 
                                                                        .addr(MEM_ALU_result[data_addr_width-1:0])
                                                                        );

    //MEM/WB reg
    PR_MEM_WB #(.word(word), .rs_lines(5)) mem_wb (.clk(clk), 
                                                   .REGwr_in(nRST ? MEM_REGwr : 1'b0), 
                                                   .WBdata_in(MEM_MEMtoREG ? MEM_data_out: MEM_ALU_result), 
                                                   .RD_in(MEM_RD), 
                                                   .REGwr_out(WB_REGwr), 
                                                   .WBdata_out(WB_WBdata), 
                                                   .RD_out(WB_RD));
    
endmodule