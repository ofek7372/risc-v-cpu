`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:47:56
// Design Name: 
// Module Name: RV32I_top
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


module RV32I_top #(parameter WIDTH=32,parameter INST_ADDR_WIDTH=10, parameter DATA_ADDR_WIDTH=10,data_base_addr='h3000)(
    input clk,
    input EN,
    input nRST ,
    output [WIDTH-1:0] dbg_PC,
    output [WIDTH-1:0] dbg_WBdata,
    output [4:0]       dbg_WBrd,
    output             dbg_WBregwr
    );
    
    wire [WIDTH-1:0] IF_PC;             // PC register output (Q)
    wire [WIDTH-1:0] IF_PC4;            // PC + 4  (inline adder)
    wire [WIDTH-1:0] IF_inst;           // instruction memory output
    wire [WIDTH-1:0] PC_in;             // next-PC mux result -> PC.D (inline)
    
    wire [WIDTH-1:0] ID_PC;
    wire [WIDTH-1:0] ID_inst;
    
    wire [3:0] ID_ALUctrl;
    wire [2:0] ID_ALUsrc;
    wire [2:0] ID_IMMsrc;
    wire       ID_REGwr;
    wire       ID_MEMwr;
    wire       ID_MEMrd;
    wire       ID_MEMtoREG;
    wire [1:0] ID_jop;
    wire       ID_bop;
    
    wire [4:0] ID_RS1; assign ID_RS1 = ID_inst[19:15];
    wire [4:0] ID_RS2; assign ID_RS2 = ID_inst[24:20];
    wire [4:0] ID_RD;  assign ID_RD  = ID_inst[11:7];
    wire [2:0] ID_funct3; assign ID_funct3 = ID_inst[14:12];
    wire       ID_funct7_5; assign ID_funct7_5=ID_inst[30];
    
    wire [WIDTH-1:0] ID_R_A_raw;
    wire [WIDTH-1:0] ID_R_B_raw;
    
    wire [WIDTH-1:0] ID_R_A;
    wire [WIDTH-1:0] ID_R_B;
    
    wire [WIDTH-1:0] ID_IMM;
    
    wire [WIDTH-1:0] EX_R_A, EX_R_B, EX_IMM, EX_PC;
    wire [2:0] EX_ALUsrc;
    wire [3:0] EX_ALUctrl;
    wire [1:0] EX_jop;
    wire       EX_bop;
    wire [4:0] EX_RS1, EX_RS2;
    wire [2:0] EX_funct3;
    wire       EX_MEMrd, EX_MEMwr, EX_MEMtoREG;
    wire [4:0] EX_RD;
    wire       EX_REGwr;
    
    wire [WIDTH-1:0] EX_A_FWD;          // = A_FWD
    wire [WIDTH-1:0] EX_B_FWD;          // = B_FWD  (also feeds EX/MEM store data)
    
    wire [WIDTH-1:0] EX_ALU_A;
    wire [WIDTH-1:0] EX_ALU_B;
    
    wire [WIDTH-1:0] EX_ALUresult;      // Y
    wire       EX_cout_borrow;
    wire       EX_zero;
   // wire       EX_negative;
    
    wire [WIDTH-1:0] EX_target;
    
    
    
    wire [WIDTH-1:0] MEM_B_FWD;
    wire [WIDTH-1:0] MEM_ALUresult;
    wire [2:0] MEM_funct3;
    wire       MEM_MEMrd, MEM_MEMwr, MEM_MEMtoREG;
    wire [4:0] MEM_RD;
    wire       MEM_REGwr;
    
    wire [DATA_ADDR_WIDTH-1:0] MEM_word_addr;  // addr decoder output (word index)
    wire [3:0]       MEM_byte_enable;          // store unit
    wire [WIDTH-1:0] MEM_data_in;              // store unit (lane-positioned)
    wire [WIDTH-1:0] MEM_data_out;             // data memory read (full word)
    wire [WIDTH-1:0] MEM_load_data;            // load unit (extract+extend)
    wire [WIDTH-1:0] MEM_WBdata;               // MEMtoREG mux result (inline) -> MEM/WB
    
    wire [WIDTH-1:0] WB_WBdata;
    wire [4:0]       WB_RD;
    wire             WB_REGwr;
    
    wire       stall;                  // asserted by thebubble insertion unit
    wire       taken;                  // asserted by the branch unit     
    wire       jump; assign jump = ((EX_jop == 2'b10) || (EX_jop == 2'b01));
     
    wire high,low;
    assign high =1'b1;
    assign low =1'b0;
    // per-register EN / FLUSH nets -- expressions worked out separately
    wire       PC_EN;
    wire       IFID_EN,  IFID_FLUSH;
    wire       IDEX_EN,  IDEX_FLUSH;
    wire       EXMEM_EN, EXMEM_FLUSH;
    wire       MEMWB_EN, MEMWB_FLUSH;
    assign PC_EN = (~stall)&EN ;
    assign IFID_EN = (~stall)&EN;
    assign IDEX_EN = EN;
    assign EXMEM_EN = EN;
    assign MEMWB_EN = EN;
    assign IFID_FLUSH = taken | jump;
    assign IDEX_FLUSH = taken | jump | stall;
    assign EXMEM_FLUSH = low;
    assign MEMWB_FLUSH = low;
    
    assign dbg_PC      = IF_PC;
    assign dbg_WBdata  = WB_WBdata;
    assign dbg_WBrd    = WB_RD;
    assign dbg_WBregwr = WB_REGwr;
    
    /*
    on stall:
    ID_EX gets flushed (bubble)
    IF_ID holds its value
    PC holds its value
    
    on branch or jump:
    PC source set target as the next PC
    IF_ID gets flushed
    ID_EX gets flushed
    
    on global reset
    all registers gets reset
    pc gets reset
    memory and register write is gated  
    */
    
    
    localparam inst_base_addr = 'h2000;
    
    assign IF_PC4 = IF_PC + 4'd4; 
    assign PC_in = ~(taken | jump) ? IF_PC4 : EX_target;
    
    wire [INST_ADDR_WIDTH-1:0] inst_addr;
    assign inst_addr = (IF_PC - inst_base_addr) >> 2 ;
    
    PC #(.WIDTH(WIDTH)) RV32I_PC (.EN(PC_EN), .nRST(nRST), .clk(clk), .D(PC_in), .Q(IF_PC));
    
    SC_instruction_mem #(.ADDR_WIDTH(INST_ADDR_WIDTH), .INST_WIDTH(WIDTH)) RV32I_INST_MEM (
    .clk(clk),
    .EN(PC_EN),
    .Addr(inst_addr),
    .inst(IF_inst),
    .FLUSH (IFID_FLUSH)
);
    wire [WIDTH-1:0] IF_PC_delayed;
    RV32I_PC_delay #(.WIDTH(WIDTH)) PC_delay_reg (
    .clk(clk),
    .EN(PC_EN),
    .nRST(nRST),
    .FLUSH(IFID_FLUSH),
    .PC_in(IF_PC),
    .PC_out(IF_PC_delayed)
);
    RV32I_IF_ID #(.WIDTH(WIDTH)) IF_ID (.clk(clk), .FLUSH(IFID_FLUSH), .EN(IFID_EN), .nRST(nRST),.IF_PC(IF_PC_delayed),.IF_inst(IF_inst),.ID_PC(ID_PC) ,.ID_inst(ID_inst));
    
    RV32I_decoder decoder(.opcode(ID_inst[6:0]), .funct3(ID_funct3), .funct7_5(ID_funct7_5),.ALUctrl(ID_ALUctrl),.ALUsrc(ID_ALUsrc),.IMMsrc(ID_IMMsrc),.jop(ID_jop),.bop(ID_bop),.MEMtoREG(ID_MEMtoREG),.MEMwr(ID_MEMwr),.MEMrd(ID_MEMrd),.REGwr(ID_REGwr));
    
    RV32I_IMMgen IMMgen (.imm_lines(ID_inst[31:7]),.IMMsrc(ID_IMMsrc),.imm(ID_IMM));
    
    SC_REG_FILE #(.REG_WIDTH(WIDTH)) REG_FILE(.RS1(ID_RS1),.RS2(ID_RS2),.RD(WB_RD),.REGwr((nRST)? WB_REGwr : 1'b0),.data_in(WB_WBdata),.clk(clk),.R_A(ID_R_A_raw),.R_B(ID_R_B_raw));
    
    REG_forwarding_unit #(.word(WIDTH)) REG_FWD (.RS1(ID_RS1),.RS2(ID_RS2),.WB_RD(WB_RD),.WB_REGwr(WB_REGwr),.r_a(ID_R_A_raw),.r_b(ID_R_B_raw),.WB_WBdata(WB_WBdata),.REG_A(ID_R_A),.REG_B(ID_R_B));
    
    RV32I_bubble bubble(.ID_RS1(ID_RS1),.ID_RS2(ID_RS2),.EX_RD(EX_RD),.EX_REGwr(EX_REGwr),.EX_MEMrd(EX_MEMrd),.EX_MEMtoREG(EX_MEMtoREG),.stall(stall));
    
    RV32I_ID_EX #(.WIDTH(WIDTH)) ID_EX ( //verified
    .clk(clk),
    .EN(IDEX_EN),
    .nRST(nRST),
    .FLUSH(IDEX_FLUSH),
    .ID_R_B(ID_R_B),
    .ID_R_A(ID_R_A),
    .ID_IMM(ID_IMM),
    .ID_PC(ID_PC),
    .ID_ALUsrc(ID_ALUsrc),
    .ID_ALUctrl(ID_ALUctrl),
    .ID_jop(ID_jop),
    .ID_bop(ID_bop),
    .ID_RS1(ID_RS1),
    .ID_RS2(ID_RS2),
    .ID_funct3(ID_funct3),
    .ID_MEMrd(ID_MEMrd),
    .ID_MEMwr(ID_MEMwr),
    .ID_MEMtoREG(ID_MEMtoREG),
    .ID_RD(ID_RD),
    .ID_REGwr(ID_REGwr),
    .EX_R_B(EX_R_B),
    .EX_R_A(EX_R_A),
    .EX_IMM(EX_IMM),
    .EX_PC(EX_PC),
    .EX_ALUsrc(EX_ALUsrc),
    .EX_ALUctrl(EX_ALUctrl),
    .EX_jop(EX_jop),
    .EX_bop(EX_bop),
    .EX_RS1(EX_RS1),
    .EX_RS2(EX_RS2),
    .EX_funct3(EX_funct3),
    .EX_MEMrd(EX_MEMrd),
    .EX_MEMwr(EX_MEMwr),
    .EX_MEMtoREG(EX_MEMtoREG),
    .EX_RD(EX_RD),
    .EX_REGwr(EX_REGwr)
    );
   
    RV32I_EX_FWD #(.WIDTH(WIDTH)) EX_FWD_unit (
    .EX_RS1(EX_RS1),
    .EX_RS2(EX_RS2),
    .MEM_RD(MEM_RD),
    .WB_RD(WB_RD),
    .MEM_REGwr(MEM_REGwr),
    .WB_REGwr(WB_REGwr),
    .MEM_WBdata(MEM_WBdata),
    .WB_WBdata(WB_WBdata),
    .EX_R_A(EX_R_A),
    .EX_R_B(EX_R_B),
    .A_FWD(EX_A_FWD),
    .B_FWD(EX_B_FWD)
    );
    
    RV32I_ALUsrc #(.WIDTH(WIDTH)) ALUsrc_unit (
    .EX_ALUsrc(EX_ALUsrc),
    .EX_IMM(EX_IMM),
    .EX_PC(EX_PC),
    .EX_R_B(EX_B_FWD),
    .EX_R_A(EX_A_FWD),
    .A(EX_ALU_A),
    .B(EX_ALU_B)
    );
    
    ALU_v1 #(.WIDTH(WIDTH)) alu (
    .a(EX_ALU_A),
    .b(EX_ALU_B),
    .alu_ctrl(EX_ALUctrl),
    .Y(EX_ALUresult),
    .zero(EX_zero),
    .cout_borrow(EX_cout_borrow)
    );
    
    RV32I_Target_adder #(.WIDTH(WIDTH)) target_adder (
    .EX_jop(EX_jop),
    .EX_PC(EX_PC),
    .EX_IMM(EX_IMM),
    .A_FWD(EX_A_FWD),
    .target(EX_target)
    );
    
    RV32I_branch #(.WIDTH(WIDTH)) branch_unit (
    .bop(EX_bop),
    .zero(EX_zero),
    .EX_funct3(EX_funct3),
    .EX_ALUresult(EX_ALUresult[0]),
    .taken(taken)
    );
    
   
 
   
   
   
    RV32I_EX_MEM #(.WIDTH(WIDTH)) EX_MEM_reg (
    .clk(clk),
    .nRST(nRST),
    .EN(EXMEM_EN),
    .FLUSH(EXMEM_FLUSH),
    .EX_B_FWD(EX_B_FWD),
    .EX_ALUresult(EX_ALUresult),
    .EX_funct3(EX_funct3),
    .EX_MEMrd(EX_MEMrd),
    .EX_MEMwr(EX_MEMwr),
    .EX_MEMtoREG(EX_MEMtoREG),
    .EX_RD(EX_RD),
    .EX_REGwr(EX_REGwr),
    .MEM_B_FWD(MEM_B_FWD),
    .MEM_ALUresult(MEM_ALUresult),
    .MEM_funct3(MEM_funct3),
    .MEM_MEMrd(MEM_MEMrd),
    .MEM_MEMwr(MEM_MEMwr),
    .MEM_MEMtoREG(MEM_MEMtoREG),
    .MEM_RD(MEM_RD),
    .MEM_REGwr(MEM_REGwr)
    );
    
    RV32I_store_unite #(.WIDTH(WIDTH)) store_unit (
    .MEM_funct3(MEM_funct3),
    .MEM_ALUresult(MEM_ALUresult[1:0]),
    .MEM_B_FWD(MEM_B_FWD),
    .byte_enable(MEM_byte_enable),
    .MEM_data_in(MEM_data_in)
    );
    
    RV32I_addr_decoder #(.data_base_address(data_base_addr), .WIDTH(WIDTH), .data_addr_width(DATA_ADDR_WIDTH)) addr_decoder (
    .ALUresult(MEM_ALUresult),
    .addr(MEM_word_addr)
    );
    
    RV32I_data_mem #(.WIDTH(WIDTH), .data_addr_width(DATA_ADDR_WIDTH)) data_mem (
    .clk(clk),
    .MEMwr((nRST) ? MEM_MEMwr : 1'b0),
    .MEMrd(MEM_MEMrd),
    .byte_enable(MEM_byte_enable),
    .addr(MEM_word_addr),
    .data_in(MEM_data_in),
    .data_out(MEM_data_out)
    );
    
    RV32I_load_unit #(.WIDTH(WIDTH)) load_unit (
    .MEM_funct3(MEM_funct3),
    .MEM_ALUresult(MEM_ALUresult[1:0]),
    .mem_data_out(MEM_data_out),
    .load_data(MEM_load_data)
    );
    
    //place holder MEMtoREG mux
   assign MEM_WBdata = (MEM_MEMtoREG)? MEM_load_data : MEM_ALUresult; 
   
   
    RV32I_MEM_WB #(.WIDTH(WIDTH)) MEM_WB_reg (
    .clk(clk),
    .EN(MEMWB_EN),
    .nRST(nRST),
    .FLUSH(MEMWB_FLUSH),
    .MEM_WBdata(MEM_WBdata),
    .MEM_RD(MEM_RD),
    .MEM_REGwr(MEM_REGwr),
    .WB_WBdata(WB_WBdata),
    .WB_RD(WB_RD),
    .WB_REGwr(WB_REGwr)
    );
    
endmodule
