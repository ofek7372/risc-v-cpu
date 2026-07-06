`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 15:31:12
// Design Name: 
// Module Name: SC_inst_mem_tb
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


module SC_inst_mem_tb ;
localparam  ADDR_WIDTH=5;
localparam  INST_WIDTH=32;

reg [ADDR_WIDTH-1:0] addr;
wire[INST_WIDTH-1:0] inst;

SC_instruction_mem DUT(.Addr(addr), .inst(inst));

integer i;
integer pass_count;
integer fail_count;
reg [INST_WIDTH-1:0] exp_inst [2**(ADDR_WIDTH)-1:0];

initial 
    begin
    i=0;
    addr=0;
    pass_count=0;
    fail_count=0;
    $readmemh("C:/Users/ec24673/project_2/mem/imem.hex", exp_inst);
    #10
    
    for (i=0 ; i<32;i=i+1)
    begin
     addr=i;
    #10
        if( inst !== exp_inst[i]) begin
            $error("T:%0d, inst:%0d, addr:%0d",i,inst,addr);
            fail_count= fail_count+1;
            end
        else 
            begin
                $display("PASS");
                pass_count=pass_count+1;
                end
                end
                $display("%0d: PASS, %0d: FAIL",pass_count, fail_count);
                $finish;
end
endmodule
