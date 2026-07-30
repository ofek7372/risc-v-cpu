`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 10:11:48
// Design Name: 
// Module Name: beu_tb
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


module beu_tb;

reg [1:0] bop;
reg [31:0] comp_a,comp_b;
wire branch;

Branch_evaluation_unit dut(.comp_a(comp_a), .comp_b(comp_b), .bop(bop), .branch(branch));

integer pass;integer fail; integer t;

reg [1:0] tv_bop [5:0];
reg [31:0] tv_comp_a [5:0];
reg [31:0] tv_comp_b [5:0];
reg exp_Branch[5:0];

task automatic check_beu;
    input [1:0] in_bop;
    input [31:0] in_comp_a, in_comp_b;
    input in_exp_branch;
    begin
    bop=in_bop; comp_a=in_comp_a;   comp_b=in_comp_b;
    #10
    if(branch !== in_exp_branch)
        begin 
            $error("T:%0d, Faild",t);
            fail=fail+1;
        end
    else begin
        $display ("T:%0d, PASS",t);
        pass=pass+1;
        end
       end
       endtask
       
initial
    begin
        fail=0;
        pass=0;
        t=0;
        //bop not a branch
        tv_bop[0]=2'b11; tv_comp_a[0]=32'd115;  tv_comp_b[0]=32'd115;   exp_Branch[0]=1'b0;
        tv_bop[1]=2'b00; tv_comp_a[1]=32'd115;  tv_comp_b[1]=32'd115;   exp_Branch[1]=1'b0;
        
        //bop-is bne and condition is equal 
         tv_bop[2]=2'b10; tv_comp_a[2]=32'd115;  tv_comp_b[2]=32'd115;   exp_Branch[2]=1'b0;
         //bop is bne and condition is not equal
         tv_bop[3]=2'b10; tv_comp_a[3]=32'd114;  tv_comp_b[3]=32'd115;   exp_Branch[3]=1'b1;
         //bop is beq and condition is not equial
          tv_bop[4]=2'b01; tv_comp_a[4]=32'd115;  tv_comp_b[4]=32'd100;   exp_Branch[4]=1'b0;
          //bop is beq and condition is equal 
          tv_bop[5]=2'b01; tv_comp_a[5]=32'd115;  tv_comp_b[5]=32'd115;   exp_Branch[5]=1'b1;
           
   for (t=0;t<6;t=t+1)
    begin
        check_beu(tv_bop[t],tv_comp_a[t],tv_comp_b[t],exp_Branch[t]);
    end
    $display("pass:%0d, fail:%0d",pass,fail);
    $finish;
    end     
endmodule
