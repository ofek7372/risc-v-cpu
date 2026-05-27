`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2026 11:07:28
// Design Name: 
// Module Name: test
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


module FA_tb ;

//reg for driving signals 
//wire for outputs
reg [3:0] a, b;
reg Cin;
wire [3:0] s;
wire Cout;
// connect the device 
FA #(.width(4)) DUT (.a(a),.b(b), .Cin(Cin),.s(s),.Cout(Cout));

initial 
begin 
//t1
a = 'd0; b='d0; Cin=1'b0;
#10; //delay 10 time unites so the signal settel 
if (s!== 'd0 || Cout!== 'd0)
$error("t1 failed: expected s=0,cout=0 got: %0d, %0d",s,Cout);
else $display("t1 pass 0+0=0");

//t2
a='d0;  b='d0;  Cin=1'b1; //assign test values 
#10; //dshort delay
if (s!==1 || Cout!==0)
$error("t2 failled expected 0+0+1=1 got %0d ",s);
else $display("t2 pass");

//t3 
a=4'd5; b=4'd7; Cin=1'b0;
#10;
if(s!== 4'd12 || Cout!==0)
$error("t3 failed expected 13 got %0d",s);
else $display("t3 pass");
$finish;
end
endmodule
