`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2026 12:29:52
// Design Name: 
// Module Name: piplined_param_tb
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


module piplined_param_tb
#(parameter NAME = "branch_test",  // any program in tests/asm: alu_fwd, branch_test, isa_cover, ...
  parameter ROOT = "");            // repo root with trailing '/'. Empty when run from the repo root;
                                   // set to an absolute path for Vivado (it runs from project_2.sim/...)

  reg [8*256-1:0] HEX_FILE, SIG_REG_FILE, SIG_MEM_FILE;
  
  localparam RUN_CYCLES = 100;
  
  localparam CHECK_MEM=1;
  localparam clk_period=10;
  localparam inst_addr_width=10;
  localparam data_addr_width=10;
  localparam WIDTH=32;
  localparam data_base_addr ='h3000;
  
  reg EN;
  reg nRST;
  reg clk;
  
RV32I_top #(.WIDTH(WIDTH),.INST_ADDR_WIDTH(inst_addr_width),.DATA_ADDR_WIDTH(data_addr_width),.data_base_addr(data_base_addr)) DUT (.EN(EN),.nRST(nRST),.clk(clk)); 
 
  //clk gen
  initial clk=1'b0;
  always #(clk_period/2) clk=~clk;
    
reg [WIDTH-1:0] sig_reg [0:WIDTH-1];
reg [WIDTH-1:0] sig_mem [0:(2**data_addr_width)-1];


reg reg_fail [0:WIDTH-1];
reg mem_fail [0:(2**data_addr_width)-1];
integer cycle;
integer i;
integer fail;
//file load
 initial
 begin
 $sformat(HEX_FILE,     "%0stests/hex/%0s_inst.hex", ROOT, NAME);
 $sformat(SIG_REG_FILE, "%0stests/sig/%0s_reg.sig",  ROOT, NAME);
 $sformat(SIG_MEM_FILE, "%0stests/sig/%0s_mem.sig",  ROOT, NAME);
 #1; // after SC_instruction_mem's own time-0 $readmemh, so this load always wins
 $readmemh(HEX_FILE, DUT.RV32I_INST_MEM.mem);
 $readmemh(SIG_REG_FILE, sig_reg);
 $readmemh(SIG_MEM_FILE, sig_mem);
 cycle=0;
 EN=1;
 nRST=0;
 fail=0;
 
 while (cycle < RUN_CYCLES)
    begin
         @(posedge clk) 
            begin 
            cycle= cycle+1;
            #1
            if (cycle==1) nRST=1'b1;
            end
    end
    for (i=0;i<WIDTH;i=i+1)
        begin
            if (DUT.REG_FILE.mem[i] !== sig_reg[i])
                begin
                reg_fail[i] = 1'b1;
                $error("fail on reg %0d",i);
                fail=fail+1;
                end
             else 
                reg_fail[i] = 1'b0;
                
        end
    if(CHECK_MEM== 1'b1)
        begin
     for (i=0;i<(2**data_addr_width);i=i+1)
        begin
            if (DUT.data_mem.mem[i] !== sig_mem[i])
                begin
                mem_fail[i] = 1'b1;
                $error("fail on mem byte %0d",i);
                fail=fail+1;
                end
             else 
                mem_fail[i] = 1'b0;
                
        end
        end
    if (fail==0)
        begin
        $display("passed");
        end
    else
    $display("%0d fails",fail);
    $finish;
    end
endmodule
