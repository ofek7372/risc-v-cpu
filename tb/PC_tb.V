`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 16:23:05
// Design Name: 
// Module Name: PC_tb
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


module PC_tb;
localparam WIDTH=5; 
localparam N=8; 
localparam clk_period=10;

reg EN; reg nRST; reg clk;
reg [WIDTH-1:0] D;
wire [WIDTH-1:0] Q;

PC DUT(.EN(EN),.nRST(nRST) ,.clk(clk),.D(D),.Q(Q));

reg [WIDTH-1:0]tv_D [N-1:0];
reg [WIDTH-1:0] exp_Q [N-1:0];
reg tv_EN [N-1:0];
reg tv_nRST [N-1:0] ;

//clk gen
initial clk='b0;
always #(clk_period/2) clk <= ~clk;
integer fail_count;
integer pass_count;
integer t;
task automatic check_PC 
    
                ( input in_EN, 
                 input in_nRST,
                 input [WIDTH-1:0]in_D,
                 input [WIDTH-1:0]exp_Q);
                 begin
                 
                 EN=in_EN; nRST=in_nRST ; D=in_D;
                 @(posedge clk)
                    #1
                 if (Q !== exp_Q)
                 begin
                 $error("T%0d failed, EN:%0d ,nRST: %0d, D:%0d, Q:%0d, exp_Q:%0d ",t,EN,nRST,D,Q,exp_Q);
                 fail_count = fail_count +1 ; 
                 end
                  else 
                  begin  
                   $display("T%0d PASS: nRST=%0d EN=%0d D=%03b Q=%0d",t,nRST,EN,D,Q);
                    pass_count=pass_count+1;
                    end
                    end
                  endtask 
                  
                  
initial
begin 
t=0;
pass_count=0;
fail_count=0;


// EN nRST D exp_Q

//increment test- regular opperation 
tv_EN [0] = 1'b1 ; tv_nRST[0]= 1'b1 ; tv_D[0]= 5'd0 ; exp_Q[0]=5'd0;
tv_EN [1] = 1'b1 ; tv_nRST[1]= 1'b1 ; tv_D[1]= 5'd3 ; exp_Q[1]=5'd3;                
tv_EN [2] = 1'b1 ; tv_nRST[2]= 1'b1 ; tv_D[2]= 5'd7 ; exp_Q[2]=5'd7;                 
//hold function                  
tv_EN [3] = 1'b0 ; tv_nRST[3]= 1'b1 ; tv_D[3]= 5'd12 ; exp_Q[3]=5'd7;
tv_EN [4] = 1'b0 ; tv_nRST[4]= 1'b1 ; tv_D[4]= 5'd0 ; exp_Q[4]=5'd7;

//reset                  
tv_EN [5] = 1'b0 ; tv_nRST[5]= 1'b0 ; tv_D[5]= 5'd12 ; exp_Q[5]=5'd0;
tv_EN [6] = 1'b1 ; tv_nRST[6]= 1'b1 ; tv_D[6]= 5'd12 ; exp_Q[6]=5'd12;
tv_EN [7] = 1'b1 ; tv_nRST[7]= 1'b0 ; tv_D[7]= 5'd30 ; exp_Q[7]=5'd0;

for (t=0; t<8; t=t+1)
begin 
    check_PC(tv_EN[t], tv_nRST[t], tv_D[t], exp_Q[t]);
end
$display("Results: %0d passed, %0d failed out of %0d tests",
                  pass_count, fail_count, N);

$finish;
end
endmodule
