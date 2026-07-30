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
#(parameter  TEST=1);
  
  localparam HEX_FILE=
    (TEST==0)? "C:/Users/ec24673/project_2/tests_mem/alu_fwd_test_inst.hex":
    (TEST==1)? "C:/Users/ec24673/project_2/tests_mem/branch_test_inst.hex":
    (TEST==2)? "C:/Users/ec24673/project_2/tests_mem/load_use_mc_inst.hex":"" ;
     
  localparam SIG_REG_FILE= 
   (TEST==0) ? "C:/Users/ec24673/project_2/signiture/test_reg.sig":
   (TEST==1)? "C:/Users/ec24673/project_2/signiture/branch_test_reg.sig":
   (TEST==2)?"C:/Users/ec24673/project_2/signiture/load_use_mc_reg.sig":"";
   
  localparam SIG_MEM_FILE= 
  (TEST==0)? "C:/Users/ec24673/project_2/signiture/test_mem.sig":
  (TEST==1)? "C:/Users/ec24673/project_2/signiture/branch_test_mem.sig":
  (TEST==2)? "C:/Users/ec24673/project_2/signiture/load_use_mc_mem.sig":"";
  
  localparam RUN_CYCLES = 100;
  
  localparam CHECK_MEM=1;
  localparam clk_period=10;
  localparam inst_addr_width=8;
  localparam data_addr_width=7;
  localparam word=32;
  
  reg EN;
  reg nRST;
  reg clk;
  
pipeline_top_module #(.word(word),.inst_addr_width(inst_addr_width),.data_addr_width(data_addr_width)) DUT (.EN(EN),.nRST(nRST),.clk(clk)); 
 
  //clk gen
  initial clk=1'b0;
  always #(clk_period/2) clk=~clk;
    
reg [word-1:0] sig_reg [0:word-1];
reg [7:0] sig_mem [0:(2**data_addr_width)-1];


reg reg_fail [0:word-1];
reg mem_fail [0:(2**data_addr_width)-1];
integer cycle;
integer i;
integer fail;
//file load
 initial
 begin
 $readmemh(HEX_FILE, DUT.inst_mem.mem);
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
    for (i=0;i<word;i=i+1)
        begin
            if (DUT.reg_file.mem[i] !== sig_reg[i])
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
