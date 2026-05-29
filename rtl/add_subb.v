`timescale 1ns / 1ps


module add_subb
#(parameter width=8)//define parameter
//define input/output
(input [width-1:0]a, b,
 input sub,
 output reg [width-1:0]s,
 output reg Cout
    );
 reg Cin;
always @(*)

begin// begin always block
Cin=1'b0;
if (sub==1'b1)
begin
Cin=1;
{Cout,s}= a + (~b)+Cin;//if sub is 1 preform 2's complement subtraction
end
else {Cout,s}= a+b+Cin;//if sub =0 preform addition
end//end allways block
 
endmodule
