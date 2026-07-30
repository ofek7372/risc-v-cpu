`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 11:31:00
// Design Name: 
// Module Name: bfu_tb
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


module bfu_tb;
localparam word=32;
localparam rs_lines=5;

reg [word-1:0] REG_A,REG_B,ALUresult,WBdata;
reg [rs_lines-1:0] RS1,RS2,EX_MEM_RD,MEM_WB_RD;
reg MEM_WB_REGwr, EX_MEM_REGwr,EX_MEM_MEMrd;
wire [word-1:0] comp_a, comp_b;

Branch_forwarding_unit dut (.REG_A(REG_A),
                            .REG_B(REG_B),
                            .ALUresult(ALUresult),
                            .WBdata(WBdata),
                            .RS1(RS1),
                            .RS2(RS2),
                            .EX_MEM_RD(EX_MEM_RD),
                            .MEM_WB_RD(MEM_WB_RD),
                            .MEM_WB_REGwr(MEM_WB_REGwr),
                            .EX_MEM_REGwr(EX_MEM_REGwr),
                            .EX_MEM_MEMrd(EX_MEM_MEMrd),
                            .comp_a(comp_a),
                            .comp_b(comp_b)
                            );
integer pass;
integer fail;
integer t;

localparam n=8;

// Input test vector arrays
reg [word-1:0]     tv_REG_A        [0:n-1];
reg [word-1:0]     tv_REG_B        [0:n-1];
reg [word-1:0]     tv_ALUresult    [0:n-1];
reg [word-1:0]     tv_WBdata       [0:n-1];
reg [rs_lines-1:0] tv_RS1          [0:n-1];
reg [rs_lines-1:0] tv_RS2          [0:n-1];
reg [rs_lines-1:0] tv_EX_MEM_RD   [0:n-1];
reg [rs_lines-1:0] tv_MEM_WB_RD   [0:n-1];
reg                tv_EX_MEM_REGwr [0:n-1];
reg                tv_MEM_WB_REGwr [0:n-1];
reg                tv_EX_MEM_MEMrd [0:n-1];

// Expected output arrays
reg [word-1:0]     exp_comp_a      [0:n-1];
reg [word-1:0]     exp_comp_b      [0:n-1];

task automatic run_test;
    input [word-1:0]     in_REG_A;
    input [word-1:0]     in_REG_B;
    input [word-1:0]     in_ALUresult;
    input [word-1:0]     in_WBdata;
    input [rs_lines-1:0] in_RS1;
    input [rs_lines-1:0] in_RS2;
    input [rs_lines-1:0] in_EX_MEM_RD;
    input [rs_lines-1:0] in_MEM_WB_RD;
    input                in_EX_MEM_REGwr;
    input                in_MEM_WB_REGwr;
    input                in_EX_MEM_MEMrd;
    input [word-1:0]     in_exp_comp_a;
    input [word-1:0]     in_exp_comp_b;
    integer pass_flag;
    begin
        REG_A        = in_REG_A;
        REG_B        = in_REG_B;
        ALUresult    = in_ALUresult;
        WBdata       = in_WBdata;
        RS1          = in_RS1;
        RS2          = in_RS2;
        EX_MEM_RD    = in_EX_MEM_RD;
        MEM_WB_RD    = in_MEM_WB_RD;
        EX_MEM_REGwr = in_EX_MEM_REGwr;
        MEM_WB_REGwr = in_MEM_WB_REGwr;
        EX_MEM_MEMrd = in_EX_MEM_MEMrd;
        #1;
        pass_flag = 1;
        if (comp_a !== in_exp_comp_a) begin
            fail = fail + 1;
            $error("T:%0d, comp_a=%0d, expected:%0d", t, comp_a, in_exp_comp_a);
            pass_flag = 0;
        end
        if (comp_b !== in_exp_comp_b) begin
            fail = fail + 1;
            $error("T:%0d, comp_b=%0d, expected:%0d", t, comp_b, in_exp_comp_b);
            pass_flag = 0;
        end
        if (pass_flag) pass = pass + 1;
    end
endtask

initial 
    begin
        pass=0;
        fail=0;
        t=0;
  //test 0 - defualt cases
tv_REG_A[0]=32'd55; tv_REG_B[0]='d125; tv_ALUresult[0]='d2; tv_WBdata[0]='d66;
    tv_RS1[0]='d1; tv_RS2[0]='d2; tv_EX_MEM_RD[0]='d3; tv_MEM_WB_RD[0]='d4;
    tv_EX_MEM_REGwr[0]='b0; tv_MEM_WB_REGwr[0]='b0; tv_EX_MEM_MEMrd[0]='b1;
    exp_comp_a[0]='d55; exp_comp_b[0]='d125;

    // Test 1: check pass both channel from the EX/MEM
    tv_REG_A[1]='d12; tv_REG_B[1]='d13; tv_ALUresult[1]='d14; tv_WBdata[1]='d15;
    tv_RS1[1]='d5; tv_RS2[1]='d5; tv_EX_MEM_RD[1]='d5; tv_MEM_WB_RD[1]='d6;
    tv_EX_MEM_REGwr[1]='b1; tv_MEM_WB_REGwr[1]='b1; tv_EX_MEM_MEMrd[1]='b0;
    exp_comp_a[1]='d14; exp_comp_b[1]='d14;

    // Test 2: check load is not passed from the ex/mem
    tv_REG_A[2]='d11; tv_REG_B[2]='d22; tv_ALUresult[2]='d33; tv_WBdata[2]='d44;
    tv_RS1[2]='d55; tv_RS2[2]='d55; tv_EX_MEM_RD[2]='d55; tv_MEM_WB_RD[2]='d66;
    tv_EX_MEM_REGwr[2]='b1; tv_MEM_WB_REGwr[2]='b1; tv_EX_MEM_MEMrd[2]='b1;
    exp_comp_a[2]='d11; exp_comp_b[2]='d22;

    // Test 3: check pass from MEM/WB
    tv_REG_A[3]='d1; tv_REG_B[3]='d2; tv_ALUresult[3]='d3; tv_WBdata[3]='d4;
    tv_RS1[3]='d5; tv_RS2[3]='d5; tv_EX_MEM_RD[3]='d2; tv_MEM_WB_RD[3]='d5;
    tv_EX_MEM_REGwr[3]='b1; tv_MEM_WB_REGwr[3]='b1; tv_EX_MEM_MEMrd[3]='b1;
    exp_comp_a[3]='d4; exp_comp_b[3]='d4;

    // Test 4: check priority chain
    tv_REG_A[4]='d0; tv_REG_B[4]='d6; tv_ALUresult[4]='d5; tv_WBdata[4]='d23;
    tv_RS1[4]='d0; tv_RS2[4]='d3; tv_EX_MEM_RD[4]='d0; tv_MEM_WB_RD[4]='d2;
    tv_EX_MEM_REGwr[4]='b1; tv_MEM_WB_REGwr[4]='b1; tv_EX_MEM_MEMrd[4]='b0;
    exp_comp_a[4]='d0; exp_comp_b[4]='d6;

  

    for (t=0; t<5; t=t+1)
        run_test(tv_REG_A[t], tv_REG_B[t], tv_ALUresult[t], tv_WBdata[t],
                 tv_RS1[t], tv_RS2[t], tv_EX_MEM_RD[t], tv_MEM_WB_RD[t],
                 tv_EX_MEM_REGwr[t], tv_MEM_WB_REGwr[t], tv_EX_MEM_MEMrd[t],
                 exp_comp_a[t], exp_comp_b[t]);

    $display("PASS:%0d, FAIL:%0d", pass, fail);
    $finish;
end
endmodule
