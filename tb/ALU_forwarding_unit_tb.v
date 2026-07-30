`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 17:24:46
// Design Name: 
// Module Name: ALU_forwarding_unit_tb
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


module ALU_forwarding_unit_tb;
localparam word=32;
localparam rs_lines=5;
localparam n=10;

reg [rs_lines-1:0] ID_EX_RS1, ID_EX_RS2, EX_MEM_RD, MEM_WB_RD;
reg [word-1:0] EX_MEM_ALUresult, MEM_WB_WBdata,ID_EX_R_A,ID_EX_R_B;
reg EX_MEM_REGwr, MEM_WB_REGwr;
wire [word-1:0] ALU_A, ALU_B;

 ALU_forwarding_unit #(.word(word), .rs_lines(rs_lines)) DUT(
                        .ID_EX_RS1(ID_EX_RS1),
                        .ID_EX_RS2(ID_EX_RS2),
                        .EX_MEM_RD(EX_MEM_RD),
                        .MEM_WB_RD(MEM_WB_RD),
                        .EX_MEM_ALUresult(EX_MEM_ALUresult),
                        .MEM_WB_WBdata(MEM_WB_WBdata),
                        .ID_EX_R_A(ID_EX_R_A),
                        .ID_EX_R_B(ID_EX_R_B),
                        .ALU_A(ALU_A),
                        .ALU_B(ALU_B),
                        .EX_MEM_REGwr(EX_MEM_REGwr),
                        .MEM_WB_REGwr(MEM_WB_REGwr)
                        );
                        

// Input test vector arrays
reg [rs_lines-1:0] tv_ID_EX_RS1     [0:n-1];
reg [rs_lines-1:0] tv_ID_EX_RS2     [0:n-1];
reg [rs_lines-1:0] tv_EX_MEM_RD     [0:n-1];
reg [rs_lines-1:0] tv_MEM_WB_RD     [0:n-1];
reg [word-1:0]     tv_EX_MEM_ALUresult [0:n-1];
reg [word-1:0]     tv_MEM_WB_WBdata    [0:n-1];
reg [word-1:0]     tv_ID_EX_R_A        [0:n-1];
reg [word-1:0]     tv_ID_EX_R_B        [0:n-1];
reg                tv_EX_MEM_REGwr     [0:n-1];
reg                tv_MEM_WB_REGwr     [0:n-1];

// Expected output arrays
reg [word-1:0]     exp_ALU_A        [0:n-1];
reg [word-1:0]     exp_ALU_B        [0:n-1];


integer t; integer pass; integer fail;
integer pass_flag;
task automatic run_test;
    input [rs_lines-1:0] in_ID_EX_RS1;
    input [rs_lines-1:0] in_ID_EX_RS2;
    input [rs_lines-1:0] in_EX_MEM_RD;
    input [rs_lines-1:0] in_MEM_WB_RD;
    input [word-1:0]     in_EX_MEM_ALUresult;
    input [word-1:0]     in_MEM_WB_WBdata;
    input [word-1:0]     in_ID_EX_R_A;
    input [word-1:0]     in_ID_EX_R_B;
    input                in_EX_MEM_REGwr;
    input                in_MEM_WB_REGwr;
    input [word-1:0]     in_exp_ALU_A;
    input [word-1:0]     in_exp_ALU_B;
    begin
        ID_EX_RS1        = in_ID_EX_RS1;
        ID_EX_RS2        = in_ID_EX_RS2;
        EX_MEM_RD        = in_EX_MEM_RD;
        MEM_WB_RD        = in_MEM_WB_RD;
        EX_MEM_ALUresult = in_EX_MEM_ALUresult;
        MEM_WB_WBdata    = in_MEM_WB_WBdata;
        ID_EX_R_A        = in_ID_EX_R_A;
        ID_EX_R_B        = in_ID_EX_R_B;
        EX_MEM_REGwr     = in_EX_MEM_REGwr;
        MEM_WB_REGwr     = in_MEM_WB_REGwr;
        #1
     
     pass_flag=1;   
     if (ALU_A !== in_exp_ALU_A)
        begin
            fail = fail + 1;
            $error("T=:%0d, ALU_A=%0d,expected:%0d ",t,ALU_A,in_exp_ALU_A);
            pass_flag=0;
        end 
     
     if (ALU_B !== in_exp_ALU_B)
        begin
            fail = fail + 1;
            $error("T=:%0d, ALU_B= %0d, expected :%0d time",t,ALU_B,in_exp_ALU_B);
            pass_flag=0;
        end 
     if(pass_flag) pass=pass+1;
    end
endtask

initial 
begin
pass=0;fail=0;t=0;

//test one passing defult 
 tv_ID_EX_RS1[0]=5'd5; tv_ID_EX_RS2[0]=5'd10; tv_EX_MEM_RD[0]=5'd10; tv_MEM_WB_RD[0]=5'd5;
    tv_EX_MEM_ALUresult[0]=32'd10; tv_MEM_WB_WBdata[0]=32'd20; tv_ID_EX_R_A[0]=32'd30; tv_ID_EX_R_B[0]=32'd40;
    tv_EX_MEM_REGwr[0]='b0; tv_MEM_WB_REGwr[0]='b0; exp_ALU_A[0]=32'd30; exp_ALU_B[0]=32'd40;

//pass MEM_WB to A and EX_MEM to B
 tv_ID_EX_RS1[1]=5'd5; tv_ID_EX_RS2[1]=5'd10; tv_EX_MEM_RD[1]=5'd10; tv_MEM_WB_RD[1]=5'd5;
    tv_EX_MEM_ALUresult[1]=32'd10; tv_MEM_WB_WBdata[1]=32'd20; tv_ID_EX_R_A[1]=32'd30; tv_ID_EX_R_B[1]=32'd40;
    tv_EX_MEM_REGwr[1]='b1; tv_MEM_WB_REGwr[1]='b1; exp_ALU_A[1]=32'd20; exp_ALU_B[1]=32'd10;
   
  //check channel A priority hairarchy 
  tv_ID_EX_RS1[2]=5'd15; tv_ID_EX_RS2[2]=5'd10; tv_EX_MEM_RD[2]=5'd15; tv_MEM_WB_RD[2]=5'd15;
    tv_EX_MEM_ALUresult[2]=32'd33; tv_MEM_WB_WBdata[2]=32'd20; tv_ID_EX_R_A[2]=32'd30; tv_ID_EX_R_B[2]=32'd40;
    tv_EX_MEM_REGwr[2]='b1; tv_MEM_WB_REGwr[2]='b1; exp_ALU_A[2]=32'd33; exp_ALU_B[2]=32'd40;   
  
  //check channel B priority hirarchy 
   tv_ID_EX_RS1[3]=5'd5; tv_ID_EX_RS2[3]=5'd13; tv_EX_MEM_RD[3]=5'd13; tv_MEM_WB_RD[3]=5'd13;
    tv_EX_MEM_ALUresult[3]=32'd55; tv_MEM_WB_WBdata[3]=32'd20; tv_ID_EX_R_A[3]=32'd30; tv_ID_EX_R_B[3]=32'd40;
    tv_EX_MEM_REGwr[3]='b1; tv_MEM_WB_REGwr[3]='b1; exp_ALU_A[3]=32'd30; exp_ALU_B[3]=32'd55;
    
    //pass EX_MEM to both channels 
     tv_ID_EX_RS1[4]=5'd3; tv_ID_EX_RS2[4]=5'd3; tv_EX_MEM_RD[4]=5'd3; tv_MEM_WB_RD[4]=5'd5;
    tv_EX_MEM_ALUresult[4]=32'd111; tv_MEM_WB_WBdata[4]=32'd20; tv_ID_EX_R_A[4]=32'd30; tv_ID_EX_R_B[4]=32'd40;
    tv_EX_MEM_REGwr[4]='b1; tv_MEM_WB_REGwr[4]='b0; exp_ALU_A[4]=32'd111; exp_ALU_B[4]=32'd111;
    
    //pass both from MEM_WB
     tv_ID_EX_RS1[5]=5'd7; tv_ID_EX_RS2[5]=5'd7; tv_EX_MEM_RD[5]=5'd3; tv_MEM_WB_RD[5]=5'd7;
    tv_EX_MEM_ALUresult[5]=32'd10; tv_MEM_WB_WBdata[5]=32'd20; tv_ID_EX_R_A[5]=32'd30; tv_ID_EX_R_B[5]=32'd40;
    tv_EX_MEM_REGwr[5]='b0; tv_MEM_WB_REGwr[5]='b1; exp_ALU_A[5]=32'd20; exp_ALU_B[5]=32'd20;
      
    for (t=0; t<6; t=t+1)
        run_test(tv_ID_EX_RS1[t], tv_ID_EX_RS2[t], tv_EX_MEM_RD[t], tv_MEM_WB_RD[t],
                 tv_EX_MEM_ALUresult[t], tv_MEM_WB_WBdata[t], tv_ID_EX_R_A[t], tv_ID_EX_R_B[t],
                 tv_EX_MEM_REGwr[t], tv_MEM_WB_REGwr[t], exp_ALU_A[t], exp_ALU_B[t]);

    $display("PASS: %0d, FAIL: %0d", pass, fail);
    $finish;

end
endmodule
