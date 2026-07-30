`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 12:01:04
// Design Name: 
// Module Name: PR_IF_ID
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


module PR_IF_ID_tb;
localparam PC=7;
localparam inst=32;
localparam clk_period=10;

reg [PC-1:0] PC_in;
reg [inst-1:0] inst_in;
reg EN,clk,nRST;
wire [PC-1:0] PC_out;
wire [inst-1:0] inst_out;

PR_IF_ID DUT(.EN(EN),
             .clk(clk),
             .nRST(nRST),
             .PC_in(PC_in),
             .PC_out(PC_out),
             .inst_in(inst_in),
             .inst_out(inst_out));

//clock generation
initial clk=0;
always #(clk_period/2) clk=~clk;

reset_check: assert property (@(posedge clk) (~nRST) |=> (inst_out=='b0 && PC_out=='b0));
EN_check: assert property (@(posedge clk) (nRST && EN)|=> ((inst_out == $past(inst_in)) && (PC_out == $past(PC_in))));
hold_check: assert property (@(posedge clk) (nRST && ~EN) |=> ((inst_out == $past(inst_out))&&(PC_out== $past(PC_out))));

initial begin
nRST = 'b0;
EN = 'b0;
PC_in =7'b0;
inst_in= 32'b0;

$display("N=0, nRST=%0b, EN=%0b,PC_in=%0h, inst_in=%0h, PC_out=%0h, inst_out=%0h",nRST,EN,PC_in,inst_in,PC_out,inst_out);

@(posedge clk)
#1;

nRST = 'b1;
EN = 'b0;
PC_in =7'd32;
inst_in= 32'd555;
$display("N=1, nRST=%0b, EN=%0b,PC_in=%0h, inst_in=%0h, PC_out=%0h, inst_out=%0h",nRST,EN,PC_in,inst_in,PC_out,inst_out);
@(posedge clk)
@(posedge clk)
#1

nRST = 'b1;
EN = 'b1;
PC_in =7'd32;
inst_in= 32'd555;
$display("N=2, nRST=%0b, EN=%0b,PC_in=%0h, inst_in=%0h, PC_out=%0h, inst_out=%0h",nRST,EN,PC_in,inst_in,PC_out,inst_out);
#5
@(posedge clk)
#1;

nRST = 'b0;
EN = 'b0;
PC_in =7'd32;
inst_in= 32'd555;

nRST = 'b1;
EN = 'b1;
PC_in =7'd127;
inst_in= 32'd555;
$display("N=3, nRST=%0b, EN=%0b,PC_in=%0h, inst_in=%0h, PC_out=%0h, inst_out=%0h",nRST,EN,PC_in,inst_in,PC_out,inst_out);
#10;
@(posedge clk) 
#1;

nRST = 'b1;
EN = 'b0;
PC_in =7'd32;
inst_in= 32'd555;
$display("N=0, nRST=%0b, EN=%0b,PC_in=%0h, inst_in=%0h, PC_out=%0h, inst_out=%0h",nRST,EN,PC_in,inst_in,PC_out,inst_out);
#5;
@(posedge clk);
#1;
nRST='b0;
#5
@(posedge clk);
#20;

$finish;
end
endmodule
