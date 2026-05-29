`timescale 1ns / 1ps

module add_subb_tb;
reg sub;
reg [15:0] a,b;
wire [15:0] s;
wire Cout;

add_subb #(.width(16)) DUT(.sub(sub), .a(a), .b(b), .Cout(Cout), .s(s));

initial 
begin
sub=1'b0; a=16'h0000 ;b=16'h0000;
#10
//check for 
if (s!==16'h0000 || Cout!==1'b0) $error("t1 faild s=%0d, cout=%0d",s,Cout);
else $display("t1 pass"); 

sub=1'b1; a=16'h0000; b=16'h0000;
#10
if(s!==16'h0000 || Cout!== 1'b0) $error("t2 faild s=%0d, cout=%0d",s,Cout);
else $display("t2 pass");

sub=1'b0; a=16'd7; b=16'd123;
#10
if(s!==16'd130 || Cout!==1'b0) $error("t3 faild s=%0d, cout=%0d",s,Cout);
else $display("t3 pass"); 


sub=1'b1; a=16'd1500; b=16'd500;
#10
if (s!==16'd1000 || Cout!==1'b0) $error("t4 faild s=%0d, Cout=%0d",s,Cout);
else $display("T4 pass");

sub=1'b0; a=16'hffff; b=16'h0001;
#10
if(s!==16'h0000 || Cout!==1'b1) $error ("T5 faild s=%0d, Cout=%0d",s,Cout);
else $display("t5 pass");
$finish;
end
endmodule
