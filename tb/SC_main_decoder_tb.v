`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 12:45:27
// Design Name: 
// Module Name: SC_main_decoder_tb
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


module SC_main_decoder_tb;

localparam N=10;
reg [6:0] oppcode;
reg [2:0] funct3;
wire [1:0] ALUop;
wire [1:0] IMMsrc;
wire [1:0] Bop;
wire ALUsrc;
wire REGwr;
wire MEMwr;
wire MEMrd;
wire MEMtoREG;

SC_main_decoder DUT(.oppcode(oppcode), 
                    .funct3(funct3),
                    .MEMtoREG(MEMtoREG),
                    .MEMrd(MEMrd),
                    .MEMwr(MEMwr),
                    .REGwr(REGwr),
                    .ALUsrc(ALUsrc),
                    .IMMsrc(IMMsrc),
                    .ALUop(ALUop),
                    .Bop(Bop)
                    );

reg [6:0] tv_oppcode [N-1:0];
reg [2:0] tv_funct3 [N-1:0];
reg [1:0] exp_ALUop [N-1:0];
reg [1:0] exp_IMMsrc [N-1:0];
reg [1:0] exp_Bop [N-1:0];
reg exp_ALUsrc [N-1:0];
reg exp_REGwr [N-1:0];
reg exp_MEMwr [N-1:0];
reg exp_MEMrd [N-1:0];
reg exp_MEMtoREG [N-1:0];
integer fail;
integer pass;
integer t;

task automatic check_decoder 
                (input [6:0]in_oppcode, 
                input [2:0] in_funct3, 
                input [1:0]in_ALUop,in_IMMsrc, in_Bop,
                input in_ALUsrc, in_REGwr,in_MEMwr, in_MEMrd,in_MEMtoREG);
                
                begin
                oppcode=in_oppcode;funct3=in_funct3;
                #10
                
                if ((ALUsrc !== in_ALUsrc)  || 
                    (IMMsrc !== in_IMMsrc)  || 
                    (in_REGwr !== REGwr)    ||
                    (in_MEMwr !== MEMwr)    ||
                    (in_MEMrd !== MEMrd)    ||
                    (in_MEMtoREG!==MEMtoREG)||
                    (in_ALUop !== ALUop)    ||
                    (in_Bop !== Bop)) 
                        begin
                    $error("T:%0d failed",t);
                    fail=fail+1;
                        end
                 else 
                    begin
                    $display("T:%0d, PASSED",t);
                    pass=pass+1;
                    end
                 end 
                 endtask
                 
                 
  
                 
   initial
    begin
        t=0;
        pass=0;
        fail=0;
        #1
        // R-type
tv_oppcode[0]=7'b0110011; tv_funct3[0]=3'b000; exp_ALUop[0]=2'b00; exp_IMMsrc[0]=2'b01; exp_Bop[0]=2'b00; exp_ALUsrc[0]=1'b0; exp_REGwr[0]=1'b1; exp_MEMwr[0]=1'b0; exp_MEMrd[0]=1'b0; exp_MEMtoREG[0]=1'b0;
// I-type ALU
tv_oppcode[1]=7'b0010011; tv_funct3[1]=3'b000; exp_ALUop[1]=2'b01; exp_IMMsrc[1]=2'b00; exp_Bop[1]=2'b00; exp_ALUsrc[1]=1'b1; exp_REGwr[1]=1'b1; exp_MEMwr[1]=1'b0; exp_MEMrd[1]=1'b0; exp_MEMtoREG[1]=1'b0;
// LW
tv_oppcode[2]=7'b0000011; tv_funct3[2]=3'b010; exp_ALUop[2]=2'b10; exp_IMMsrc[2]=2'b00; exp_Bop[2]=2'b00; exp_ALUsrc[2]=1'b1; exp_REGwr[2]=1'b1; exp_MEMwr[2]=1'b0; exp_MEMrd[2]=1'b1; exp_MEMtoREG[2]=1'b1;
// SW
tv_oppcode[3]=7'b0100011; tv_funct3[3]=3'b010; exp_ALUop[3]=2'b10; exp_IMMsrc[3]=2'b11; exp_Bop[3]=2'b00; exp_ALUsrc[3]=1'b1; exp_REGwr[3]=1'b0; exp_MEMwr[3]=1'b1; exp_MEMrd[3]=1'b0; exp_MEMtoREG[3]=1'b0;
// BEQ
tv_oppcode[4]=7'b1100011; tv_funct3[4]=3'b000; exp_ALUop[4]=2'b11; exp_IMMsrc[4]=2'b11; exp_Bop[4]=2'b10; exp_ALUsrc[4]=1'b1; exp_REGwr[4]=1'b0; exp_MEMwr[4]=1'b0; exp_MEMrd[4]=1'b0; exp_MEMtoREG[4]=1'b0;
// BNE
tv_oppcode[5]=7'b1100011; tv_funct3[5]=3'b001; exp_ALUop[5]=2'b11; exp_IMMsrc[5]=2'b11; exp_Bop[5]=2'b01; exp_ALUsrc[5]=1'b1; exp_REGwr[5]=1'b0; exp_MEMwr[5]=1'b0; exp_MEMrd[5]=1'b0; exp_MEMtoREG[5]=1'b0;
// Default (invalid opcode)
tv_oppcode[6]=7'b1111111; tv_funct3[6]=3'b000; exp_ALUop[6]=2'b00; exp_IMMsrc[6]=2'b00; exp_Bop[6]=2'b00; exp_ALUsrc[6]=1'b0; exp_REGwr[6]=1'b0; exp_MEMwr[6]=1'b0; exp_MEMrd[6]=1'b0; exp_MEMtoREG[6]=1'b0;
         
 for (t=0;t<7;t=t+1)
    check_decoder(tv_oppcode[t],tv_funct3[t],exp_ALUop[t],exp_IMMsrc[t],exp_Bop[t],exp_ALUsrc[t],exp_REGwr[t],exp_MEMwr[t],exp_MEMrd[t],exp_MEMtoREG[t]);
    $display("PASS: %0d, fail:%0d",pass,fail);
    $finish;
    end                   
                
endmodule
