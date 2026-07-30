`timescale 1ns / 1ps

//THIS TB tested the datapath connections of the piplined version current state: PASSED 
/*
the program used:

addi x1,x0,1
addi x2,x0,2
addi x3,x0,3
addi x4,x0,4
sw x1,0(x0)
sw x2,4(x0)
sw x3,8(x0)
sw x4,12(x0)
lw x5,0(x0)
lw x6,4(x0)
lw x7,8(x0)
lw x8,12(x0)
xor x1,x1,x5
xor x2,x2,x6

*/

module pipeline_top_tb;
localparam clk_period=10;
reg EN;
reg nRST;
reg clk;
localparam  HEX_FILE="C:/Users/ec24673/project_2/mem/imem.hex";
localparam word =32;
localparam inst_addr_width=8;
localparam data_addr_width=7;
pipeline_top_module #(.word(word),.inst_addr_width(inst_addr_width),.data_addr_width(data_addr_width), .HEX_FILE(HEX_FILE)) DUT(.EN(EN), .nRST(nRST), .clk(clk));

wire condition;
assign condition = ((DUT.reg_file.mem[1] == 32'd0) && (DUT.reg_file.mem[2] == 32'b0) && (DUT.reg_file.mem[7] == 32'd3));
//clk gen
initial clk =1'b0;
always #(clk_period/2) clk=~clk;

integer fail;
integer cycle;

task automatic check_cycle_5;
 begin
 if (DUT.IF_ID_inst[6:0] !== 7'b0010011) begin fail=fail+1; $error("C5 opcode=%b exp 0010011",DUT.IF_ID_inst[6:0]); end
 if (DUT.ID_ALUop !== 2'b01) begin fail=fail+1; $error("C5 ID_ALUop=%b exp 01",DUT.ID_ALUop); end
 if (DUT.ID_ALUsrc !== 1'b1) begin fail=fail+1; $error("C5 ID_ALUsrc=%b exp 1",DUT.ID_ALUsrc); end
 if (DUT.ID_imm !== 32'd4) begin fail=fail+1; $error("C5 ID_imm=%0d exp 4",DUT.ID_imm); end
 if (DUT.ID_REGwr !== 1'b1) begin fail=fail+1; $error("C5 ID_REGwr=%b exp 1",DUT.ID_REGwr); end
 if (DUT.ID_MEMwr !== 1'b0) begin fail=fail+1; $error("C5 ID_MEMwr=%b exp 0",DUT.ID_MEMwr); end
 if (DUT.ID_MEMrd !== 1'b0) begin fail=fail+1; $error("C5 ID_MEMrd=%b exp 0",DUT.ID_MEMrd); end
 if (DUT.ID_MEMtoREG !== 1'b0) begin fail=fail+1; $error("C5 ID_MEMtoREG=%b exp 0",DUT.ID_MEMtoREG); end
 if (DUT.ID_Bop !== 2'b00) begin fail=fail+1; $error("C5 ID_Bop=%b exp 00",DUT.ID_Bop); end
 if (DUT.EX_imm !== 32'd3) begin fail=fail+1; $error("C5 EX_imm=%0d exp 3",DUT.EX_imm); end
 if (DUT.EX_RD !== 5'd3) begin fail=fail+1; $error("C5 EX_RD=%0d exp 3",DUT.EX_RD); end
 if (DUT.EX_ALUop !== 2'b01) begin fail=fail+1; $error("C5 EX_ALUop=%b exp 01",DUT.EX_ALUop); end
 if (DUT.EX_ALUsrc !== 1'b1) begin fail=fail+1; $error("C5 EX_ALUsrc=%b exp 1",DUT.EX_ALUsrc); end
 if (DUT.EX_REGwr !== 1'b1) begin fail=fail+1; $error("C5 EX_REGwr=%b exp 1",DUT.EX_REGwr); end
 if (DUT.EX_ALU_ctrl !== 3'b000) begin fail=fail+1; $error("C5 EX_ALU_ctrl=%b exp 000",DUT.EX_ALU_ctrl); end
 if (DUT.MEM_ALU_result !== 32'd2) begin fail=fail+1; $error("C5 MEM_ALU_result=%0d exp 2",DUT.MEM_ALU_result); end
 if (DUT.WB_WBdata !== 32'd1) begin fail=fail+1; $error("C5 WB_WBdata=%0d exp 1",DUT.WB_WBdata); end
 end
endtask

task automatic check_cycle_9;
 begin
 if (DUT.IF_ID_inst !== 32'h00402623) begin fail=fail+1; $error("C9 inst=%h exp 00402623",DUT.IF_ID_inst); end
 if (DUT.ID_ALUop !== 2'b10) begin fail=fail+1; $error("C9 ID_ALUop=%b exp 10",DUT.ID_ALUop); end
 if (DUT.ID_ALUsrc !== 1'b1) begin fail=fail+1; $error("C9 ID_ALUsrc=%b exp 1",DUT.ID_ALUsrc); end
 if (DUT.ID_IMMsrc !== 2'b11) begin fail=fail+1; $error("C9 ID_IMMsrc=%b exp 11",DUT.ID_IMMsrc); end
 if (DUT.ID_REGwr !== 1'b0) begin fail=fail+1; $error("C9 ID_REGwr=%b exp 0",DUT.ID_REGwr); end
 if (DUT.ID_MEMwr !== 1'b1) begin fail=fail+1; $error("C9 ID_MEMwr=%b exp 1",DUT.ID_MEMwr); end
 if (DUT.ID_MEMrd !== 1'b0) begin fail=fail+1; $error("C9 ID_MEMrd=%b exp 0",DUT.ID_MEMrd); end
 if (DUT.ID_MEMtoREG !== 1'b0) begin fail=fail+1; $error("C9 ID_MEMtoREG=%b exp 0",DUT.ID_MEMtoREG); end
 if (DUT.EX_imm !== 32'd8) begin fail=fail+1; $error("C9 EX_imm=%0d exp 8",DUT.EX_imm); end
 if (DUT.EX_ALU_ctrl !== 3'b000) begin fail=fail+1; $error("C9 EX_ALU_ctrl=%b exp 000",DUT.EX_ALU_ctrl); end
 if (DUT.MEM_ALU_result[6:0] !== 7'd4) begin fail=fail+1; $error("C9 mem addr=%0d exp 4",DUT.MEM_ALU_result[6:0]); end
 if (DUT.MEM_R_B !== 32'd2) begin fail=fail+1; $error("C9 MEM_R_B=%0d exp 2",DUT.MEM_R_B); end
 if (DUT.MEM_MEMwr !== 1'b1) begin fail=fail+1; $error("C9 MEM_MEMwr=%b exp 1",DUT.MEM_MEMwr); end
 if (DUT.WB_REGwr !== 1'b0) begin fail=fail+1; $error("C9 WB_REGwr=%b exp 0",DUT.WB_REGwr); end
 if (DUT.reg_file.mem[1] !== 32'd1) begin fail=fail+1; $error("C9 x1=%0d exp 1",DUT.reg_file.mem[1]); end
 if (DUT.reg_file.mem[2] !== 32'd2) begin fail=fail+1; $error("C9 x2=%0d exp 2",DUT.reg_file.mem[2]); end
 if (DUT.reg_file.mem[3] !== 32'd3) begin fail=fail+1; $error("C9 x3=%0d exp 3",DUT.reg_file.mem[3]); end
 if (DUT.reg_file.mem[4] !== 32'd4) begin fail=fail+1; $error("C9 x4=%0d exp 4",DUT.reg_file.mem[4]); end
 end
endtask

task automatic check_cycle_13;
 begin
 if (DUT.ID_ALUop !== 2'b10) begin fail=fail+1; $error("C13 ID_ALUop=%b exp 10",DUT.ID_ALUop); end
 if (DUT.ID_ALUsrc !== 1'b1) begin fail=fail+1; $error("C13 ID_ALUsrc=%b exp 1",DUT.ID_ALUsrc); end
 if (DUT.ID_IMMsrc !== 2'b00) begin fail=fail+1; $error("C13 ID_IMMsrc=%b exp 00",DUT.ID_IMMsrc); end
 if (DUT.ID_REGwr !== 1'b1) begin fail=fail+1; $error("C13 ID_REGwr=%b exp 1",DUT.ID_REGwr); end
 if (DUT.ID_MEMwr !== 1'b0) begin fail=fail+1; $error("C13 ID_MEMwr=%b exp 0",DUT.ID_MEMwr); end
 if (DUT.ID_MEMrd !== 1'b1) begin fail=fail+1; $error("C13 ID_MEMrd=%b exp 1",DUT.ID_MEMrd); end
 if (DUT.ID_MEMtoREG !== 1'b1) begin fail=fail+1; $error("C13 ID_MEMtoREG=%b exp 1",DUT.ID_MEMtoREG); end
 if (DUT.ID_Bop !== 2'b00) begin fail=fail+1; $error("C13 ID_Bop=%b exp 00",DUT.ID_Bop); end
 if (DUT.EX_imm !== 32'd8) begin fail=fail+1; $error("C13 EX_imm=%0d exp 8",DUT.EX_imm); end
 if (DUT.EX_RD !== 5'd7) begin fail=fail+1; $error("C13 EX_RD=%0d exp 7",DUT.EX_RD); end
 if (DUT.EX_ALU_ctrl !== 3'b000) begin fail=fail+1; $error("C13 EX_ALU_ctrl=%b exp 000",DUT.EX_ALU_ctrl); end
 if (DUT.MEM_ALU_result[6:0] !== 7'd4) begin fail=fail+1; $error("C13 mem addr=%0d exp 4",DUT.MEM_ALU_result[6:0]); end
 if (DUT.MEM_data_out !== 32'd2) begin fail=fail+1; $error("C13 MEM_data_out=%0d exp 2",DUT.MEM_data_out); end
 if (DUT.WB_WBdata !== 32'd1) begin fail=fail+1; $error("C13 WB_WBdata=%0d exp 1",DUT.WB_WBdata); end
 if (DUT.WB_RD !== 5'd5) begin fail=fail+1; $error("C13 WB_RD=%0d exp 5",DUT.WB_RD); end
 if (DUT.WB_REGwr !== 1'b1) begin fail=fail+1; $error("C13 WB_REGwr=%b exp 1",DUT.WB_REGwr); end
 end
endtask

task automatic check_cycle_16;
 begin
 if (DUT.EX_ALU_ctrl !== 3'b100) begin fail=fail+1; $error("C16 EX_ALU_ctrl=%b exp 100",DUT.EX_ALU_ctrl); end
 if (DUT.MEM_ALU_result !== 32'd0) begin fail=fail+1; $error("C16 MEM_ALU_result=%0d exp 0",DUT.MEM_ALU_result); end
 if (DUT.MEM_RD !== 5'd1) begin fail=fail+1; $error("C16 MEM_RD=%0d exp 1",DUT.MEM_RD); end
 if (DUT.MEM_REGwr !== 1'b1) begin fail=fail+1; $error("C16 MEM_REGwr=%b exp 1",DUT.MEM_REGwr); end
 end
endtask

initial 
begin
    cycle =0;
    nRST = 0;
    EN=1;
    fail=0;
    
    while ((~condition) || (cycle !== 25))
        begin
        @(posedge clk) 
            begin 
            cycle= cycle+1;
            #1
            if (cycle==1) nRST=1'b1;
            end
        @(negedge clk)
            begin
            if (cycle == 5) check_cycle_5;
            if (cycle == 9) check_cycle_9;
            if (cycle == 13)check_cycle_13;
            if (cycle == 16)check_cycle_16;
            end
        end
 if(cycle == 25) $display("stancile condition did not work properly");       
 if (DUT.reg_file.mem[1] !== 32'd0) begin fail=fail+1; $error("C:%0d, x1 contain:%0d, expected:0",cycle,DUT.reg_file.mem[1]); end
 if (DUT.reg_file.mem[2] !== 32'd0) begin fail=fail+1; $error("C:%0d, x2 contain:%0d, expected:0",cycle,DUT.reg_file.mem[2]); end
 if (DUT.reg_file.mem[3] !== 32'd3) begin fail=fail+1; $error("C:%0d, x3 contain:%0d, expected:3",cycle,DUT.reg_file.mem[3]); end
 if (DUT.reg_file.mem[4] !== 32'd4) begin fail=fail+1; $error("C:%0d, x4 contain:%0d, expected:4",cycle,DUT.reg_file.mem[4]); end
 if (DUT.reg_file.mem[5] !== 32'd1) begin fail=fail+1; $error("C:%0d, x5 contain:%0d, expected:1",cycle,DUT.reg_file.mem[5]); end
 if (DUT.reg_file.mem[6] !== 32'd2) begin fail=fail+1; $error("C:%0d, x6 contain:%0d, expected:2",cycle,DUT.reg_file.mem[6]); end
 if (DUT.reg_file.mem[7] !== 32'd3) begin fail=fail+1; $error("C:%0d, x7 contain:%0d, expected:3",cycle,DUT.reg_file.mem[7]); end
 if (DUT.reg_file.mem[8] !== 32'd4) begin fail=fail+1; $error("C:%0d, x8 contain:%0d, expected:4",cycle,DUT.reg_file.mem[8]); end
     
if({DUT.data_mem.mem[3], DUT.data_mem.mem[2],DUT.data_mem.mem[1],DUT.data_mem.mem[0]} !== 32'b1) begin fail=fail+1; $error("C:%0d, mem[0] word :%0d, expected: 32'b1",cycle,({DUT.data_mem.mem[3], DUT.data_mem.mem[2],DUT.data_mem.mem[1],DUT.data_mem.mem[0]})); end
if({DUT.data_mem.mem[7], DUT.data_mem.mem[6],DUT.data_mem.mem[5],DUT.data_mem.mem[4]} !== 32'd2) begin fail=fail+1; $error("C:%0d, mem[4] word :%0d, expected: 32'd2",cycle,({DUT.data_mem.mem[7], DUT.data_mem.mem[6],DUT.data_mem.mem[5],DUT.data_mem.mem[4]})); end
if({DUT.data_mem.mem[11], DUT.data_mem.mem[10],DUT.data_mem.mem[9],DUT.data_mem.mem[8]} !== 32'd3) begin fail=fail+1; $error("C:%0d, mem[8] word :%0d, expected: 32'd3",cycle,({DUT.data_mem.mem[11], DUT.data_mem.mem[10],DUT.data_mem.mem[9],DUT.data_mem.mem[8]})); end
if({DUT.data_mem.mem[15], DUT.data_mem.mem[14],DUT.data_mem.mem[13],DUT.data_mem.mem[12]} !== 32'd4) begin fail=fail+1; $error("C:%0d, mem[12] word :%0d, expected: 32'd4",cycle,({DUT.data_mem.mem[15], DUT.data_mem.mem[14],DUT.data_mem.mem[13],DUT.data_mem.mem[12]})); end
if(fail == 'd0) $display("Passed");
else $display("fails:%0d",fail);

$finish;
end
endmodule
