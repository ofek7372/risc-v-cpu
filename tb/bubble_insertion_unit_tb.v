`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 15:29:22
// Design Name: 
// Module Name: bubble_insertion_unit_tb
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



module bubble_insertion_unit_tb;
localparam rs_lines = 5;
localparam n = 8;
localparam bne=2'b10;
localparam beq=2'b01;
localparam nb=2'b00; //stand for not branch
reg [1:0] bop;
reg [rs_lines-1:0] RS1, RS2, ID_EX_RD, EX_MEM_RD;
reg EX_MEM_REGwr, EX_MEM_MEMrd, ID_EX_REGwr, ID_EX_MEMrd;
wire stall;

bubble_insertion_unit #(.rs_lines(rs_lines)) DUT (
    .bop(bop),
    .RS1(RS1),
    .RS2(RS2),
    .ID_EX_RD(ID_EX_RD),
    .EX_MEM_RD(EX_MEM_RD),
    .EX_MEM_REGwr(EX_MEM_REGwr),
    .EX_MEM_MEMrd(EX_MEM_MEMrd),
    .ID_EX_REGwr(ID_EX_REGwr),
    .ID_EX_MEMrd(ID_EX_MEMrd),
    .stall(stall)
);

// Input test vector arrays
reg [1:0] tv_bop [0:n-1];
reg [rs_lines-1:0] tv_RS1 [0:n-1];
reg [rs_lines-1:0] tv_RS2 [0:n-1];
reg [rs_lines-1:0] tv_ID_EX_RD [0:n-1];
reg [rs_lines-1:0] tv_EX_MEM_RD [0:n-1];
reg tv_EX_MEM_REGwr[0:n-1];
reg tv_EX_MEM_MEMrd [0:n-1];
reg tv_ID_EX_REGwr  [0:n-1];
reg tv_ID_EX_MEMrd  [0:n-1];

// Expected output array
reg exp_stall [0:n-1];

integer pass, fail, t;
integer pass_flag;

task automatic run_test;
    input [1:0] in_bop;
    input [rs_lines-1:0] in_RS1;
    input [rs_lines-1:0] in_RS2;
    input [rs_lines-1:0] in_ID_EX_RD;
    input [rs_lines-1:0] in_EX_MEM_RD;
    input in_EX_MEM_REGwr;
    input in_EX_MEM_MEMrd;
    input in_ID_EX_REGwr;
    input in_ID_EX_MEMrd;
    input in_exp_stall;
    begin
        bop = in_bop;
        RS1 = in_RS1;
        RS2 = in_RS2;
        ID_EX_RD= in_ID_EX_RD;
        EX_MEM_RD= in_EX_MEM_RD;
        EX_MEM_REGwr = in_EX_MEM_REGwr;
        EX_MEM_MEMrd = in_EX_MEM_MEMrd;
        ID_EX_REGwr= in_ID_EX_REGwr;
        ID_EX_MEMrd = in_ID_EX_MEMrd;
        #1;
        pass_flag = 1;
        if (stall !== in_exp_stall) begin
            fail = fail + 1;
            $error("T:%0d, stall=%0b, expected:%0b", t, stall, in_exp_stall);
            pass_flag = 0;
        end
        if (pass_flag) pass = pass + 1;
    end
endtask

initial begin
    pass=0; fail=0; t=0;

    // Test 0: check stall from use-branch 
    tv_bop[0]=bne; tv_RS1[0]='d5; tv_RS2[0]='d1; tv_ID_EX_RD[0]='d5; tv_EX_MEM_RD[0]='d5;
    tv_EX_MEM_REGwr[0]='b0; tv_EX_MEM_MEMrd[0]='d0; tv_ID_EX_REGwr[0]='b1; tv_ID_EX_MEMrd[0]='b0;
    exp_stall[0]=1'b1;
    
    // Test 1:test for second babble load-branch case 
    tv_bop[1]=beq; tv_RS1[1]='d2; tv_RS2[1]='d10; tv_ID_EX_RD[1]='d1; tv_EX_MEM_RD[1]='d10;
    tv_EX_MEM_REGwr[1]='b1; tv_EX_MEM_MEMrd[1]='b1; tv_ID_EX_REGwr[1]='b1; tv_ID_EX_MEMrd[1]='b0;
    exp_stall[1]=1'b1;
    // Test 2: test load-use bubble
    tv_bop[2]=nb; tv_RS1[2]='b1; tv_RS2[2]='d3; tv_ID_EX_RD[2]='d1; tv_EX_MEM_RD[2]='d5;
    tv_EX_MEM_REGwr[2]='d0; tv_EX_MEM_MEMrd[2]='d1; tv_ID_EX_REGwr[2]='d1; tv_ID_EX_MEMrd[2]='d1;
    exp_stall[2]='b1;
    // Test 3: 
    tv_bop[3]=nb; tv_RS1[3]='d12; tv_RS2[3]='d12; tv_ID_EX_RD[3]='d12; tv_EX_MEM_RD[3]='d12;
    tv_EX_MEM_REGwr[3]=1'b1; tv_EX_MEM_MEMrd[3]='b0; tv_ID_EX_REGwr[3]='b1; tv_ID_EX_MEMrd[3]='b0;
    exp_stall[3]='b0;

    for (t=0; t<4; t=t+1)
        run_test(tv_bop[t], tv_RS1[t], tv_RS2[t], tv_ID_EX_RD[t], tv_EX_MEM_RD[t],
                 tv_EX_MEM_REGwr[t], tv_EX_MEM_MEMrd[t], tv_ID_EX_REGwr[t], tv_ID_EX_MEMrd[t],
                 exp_stall[t]);

    $display("PASS:%0d, FAIL:%0d", pass, fail);
    $finish;
end
endmodule
