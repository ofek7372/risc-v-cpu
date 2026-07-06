`timescale 1ns / 1ps


module SC_imm_gen_tb;
localparam N=10;
reg [1:0] IMMsrc;
reg [31:7] imm_lines;
wire[31:0] imm;

SC_imm_gen DUT(.IMMsrc(IMMsrc), .imm_lines(imm_lines), .imm(imm));

reg [1:0] tv_IMMsrc [N-1:0];
reg [31:7] tv_imm_lines [N-1:0];
reg [31:0] exp_imm [N-1:0];
integer fail;
integer pass;
integer t;

task automatic check_immgen (input [31:7] in_imm_lines ,input[1:0] in_IMMsrc, input[31:0]in_exp_imm);
    begin
    imm_lines=in_imm_lines; IMMsrc=in_IMMsrc; 
    #10
    if (imm !== in_exp_imm) 
        begin
            $error("T:%0d failed imm:%0h, expected:%08h, tv_imm_lines:%08h, DUT imm lines: %08h",t,imm,in_exp_imm,tv_imm_lines[t],DUT.imm_lines);
            fail=fail+1;
            end
         else
            begin
                $display("T:%0d, passed imm:%0d, expected :%0d",t,imm,in_exp_imm);
                pass=pass+1;
                end
   end
   endtask

initial
    begin
        pass=0;
        fail=0;
        t=0;
        
        tv_IMMsrc[0] =2'b01;  tv_imm_lines[0]=25'b1;                          exp_imm[0]=32'b0;
        // sign extend 1
        tv_IMMsrc[1] =2'b00;  tv_imm_lines[1]={1'b1,{24{1'b0}}};              exp_imm[1]={{21{1'b1}},{11{1'b0}}};
        // sign extend 0
        tv_IMMsrc[2] =2'b00;  tv_imm_lines[2]={1'b0,{24{1'b1}}};              exp_imm[2]={{21{1'b0}},{11{1'b1}}};
        
        tv_IMMsrc[3] =2'b11;  tv_imm_lines[3]={7'b1100011,13'b0,5'b01010};    exp_imm[3]={{20{1'b1}},12'b110001101010};
        tv_IMMsrc[4] =2'b11;  tv_imm_lines[4]={7'h0f,13'b0,5'b11111};         exp_imm[4]={{20{1'b0}},12'h01ff};
        
        tv_IMMsrc[5] =2'b10;  tv_imm_lines[5]={20'h7fff,5'b0};                exp_imm[5]={20'h7fff,12'h0};
        tv_IMMsrc[6] =2'b10;  tv_imm_lines[6]={20'hfffff,5'b0};               exp_imm[6]={20'hfffff,12'h0};
        
        for (t=0; t<7; t=t+1)
        check_immgen(tv_imm_lines[t], tv_IMMsrc[t], exp_imm[t]);
        $display("pass:%0d, fail:%0d",pass,fail);
        $finish;
        end

endmodule
