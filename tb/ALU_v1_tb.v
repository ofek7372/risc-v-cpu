`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 15:36:17
// Design Name: 
// Module Name: ALU_v1_tb
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


module ALU_v1_tb;
 //local parameters 
 localparam WIDTH=8;
 localparam N=21;

//testbench signals for the DUT instance 
  reg [WIDTH-1:0] a,b;
  reg [2:0] alu_ctrl;
  wire [WIDTH-1:0] Y;
  wire cout_borrow,zero,negative;
  
  //dut instance 
  ALU_v1 #(.WIDTH(WIDTH)) DUT (.a(a),
                              .b(b),
                              .alu_ctrl(alu_ctrl),
                              .Y(Y), 
                              .cout_borrow(cout_borrow), 
                              .zero(zero), 
                              .negative(negative));

//test vector array
reg [WIDTH-1:0] tv_a [0:N-1];
reg [WIDTH-1:0] tv_b [0:N-1];
reg [WIDTH-1:0] tv_expY [0:N-1];
reg [2:0]       tv_ctrl [0:N-1];
reg             tv_cout [0:N-1]; 
reg             tv_zero [0:N-1];
 




//test monitor variables 
integer t;
integer pass_count;
integer fail_count;

//test task 
task automatic check_alu;
                  input [WIDTH-1:0] in_a, in_b, exp_Y ;
                  input [2:0] ctrl;
                  input exp_cout,exp_zero;
                  begin
                  a=in_a;b=in_b;alu_ctrl=ctrl;
                  #10;
                  
                  if(Y!==exp_Y || cout_borrow !== exp_cout || exp_zero!==zero  )
                  begin
                    $error("T%0d FAIL: a=%0d b=%0d ctrl=%03b | got Y=%0d cout=%0b zero=%0b | exp Y=%0d cout=%0b zero=%0b",
                    t,a,b,alu_ctrl,Y,cout_borrow,zero,exp_Y,exp_cout,exp_zero );
                    fail_count= fail_count+1;
                  end
                  
                  else 
                  begin  
                   $display("T%0d PASS: a=%0d b=%0d ctrl=%03b | Y=%0d",t,a,b,alu_ctrl,Y);
                    pass_count=pass_count+1;
                    end
                    end
                  endtask  
                  

initial
begin
pass_count=0;
fail_count=0;
t=0;
//load vectors 
// ctrl     a    b    y   cout   zero
//add tests
tv_ctrl[0]=3'b000; tv_a[0]=8'd3; tv_b[0]=8'd10; tv_expY[0]=8'd13; tv_cout[0]=1'b0; tv_zero[0]=1'b0; 
tv_ctrl[1]=3'b000; tv_a[1]=8'd255; tv_b[1]=8'd1; tv_expY[1]=8'd0; tv_cout[1]=1'b1; tv_zero[1]=1'b1;
tv_ctrl[2]=3'b000; tv_a[2]=8'd255; tv_b[2]=8'd255; tv_expY[2]=8'd254; tv_cout[2]=1'b1; tv_zero[2]=1'b0;
tv_ctrl[3]=3'b000; tv_a[3]=8'd245; tv_b[3]=8'd10; tv_expY[3]=8'd255; tv_cout[3]=1'b0; tv_zero[3]=1'b0;  

//subb tests
tv_ctrl[5]=3'b001; tv_a[5]=8'd255; tv_b[5]=8'd55; tv_expY[5]=8'd200; tv_cout[5]=1'b0; tv_zero[5]=1'b0; 
tv_ctrl[6]=3'b001; tv_a[6]=8'd255; tv_b[6]=8'd255; tv_expY[6]=8'd0; tv_cout[6]=1'b0; tv_zero[6]=1'b1; 
tv_ctrl[7]=3'b001; tv_a[7]=8'd0; tv_b[7]=8'd1; tv_expY[7]=8'd255; tv_cout[7]=1'b1; tv_zero[7]=1'b0;

//and tests
tv_ctrl[8]=3'b010; tv_a[8]=8'd255; tv_b[8]=8'd255; tv_expY[8]=8'd255; tv_cout[8]=1'b0; tv_zero[8]=1'b0;
tv_ctrl[9]=3'b010; tv_a[9]=8'd0; tv_b[9]=8'd255; tv_expY[9]=8'd0; tv_cout[9]=1'b0; tv_zero[9]=1'b1;
tv_ctrl[10]=3'b010; tv_a[10]=8'b10101010; tv_b[10]=8'b10101010; tv_expY[10]=8'b10101010; tv_cout[10]=1'b0; tv_zero[10]=1'b0;

//or test 
tv_ctrl[11]=3'b011; tv_a[11]=8'd255; tv_b[11]=8'd0; tv_expY[11]=8'd255; tv_cout[11]=1'b0; tv_zero[11]=1'b0;
tv_ctrl[12]=3'b011; tv_a[12]=8'd0; tv_b[12]=8'd0; tv_expY[12]=8'd0; tv_cout[12]=1'b0; tv_zero[12]=1'b1;
tv_ctrl[4]=3'b011; tv_a[4]=8'b10101010; tv_b[4]=8'b01010101; tv_expY[4]=8'b11111111; tv_cout[4]=1'b0; tv_zero[4]=1'b0;

//xor
tv_ctrl[14]=3'b100; tv_a[14]=8'd255; tv_b[14]=8'd0; tv_expY[14]=8'd255; tv_cout[14]=1'b0; tv_zero[14]=1'b0;
tv_ctrl[15]=3'b100; tv_a[15]=8'd255; tv_b[15]=8'd255; tv_expY[15]=8'd0; tv_cout[15]=1'b0; tv_zero[15]=1'b1;
tv_ctrl[16]=3'b100; tv_a[16]=8'b11110000; tv_b[16]=8'b11000000; tv_expY[16]=8'b00110000; tv_cout[16]=1'b0; tv_zero[16]=1'b0;

//slt
tv_ctrl[17]=3'b101; tv_a[17]=8'd2; tv_b[17]=8'd4; tv_expY[17]=8'd1; tv_cout[17]=1'b0; tv_zero[17]=1'b0;
tv_ctrl[18]=3'b101; tv_a[18]=8'd8; tv_b[18]=8'd4; tv_expY[18]=8'd0; tv_cout[18]=1'b0; tv_zero[18]=1'b1;
tv_ctrl[19]=3'b101; tv_a[19]=8'd4; tv_b[19]=8'd4; tv_expY[19]=8'd0; tv_cout[19]=1'b0; tv_zero[19]=1'b1;

//sll test
tv_ctrl[20]=3'b110; tv_a[20]=8'd255; tv_b[20]=8'd4; tv_expY[20]=8'd254; tv_cout[20]=1'b0; tv_zero[20]=1'b0;
//srl test
tv_ctrl[13]=3'b111; tv_a[13]=8'd255; tv_b[13]=8'd4; tv_expY[13]=8'd127; tv_cout[13]=1'b0; tv_zero[13]=1'b0;


for (t=0; t<N; t=t+1) begin
check_alu(tv_a[t], tv_b[t], tv_expY[t], tv_ctrl[t],tv_cout[t], tv_zero[t]);
end
$display("Results: %0d passed, %0d failed out of %0d tests",
                  pass_count, fail_count, N);

$finish;
end
endmodule
