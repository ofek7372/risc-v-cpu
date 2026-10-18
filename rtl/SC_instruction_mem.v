`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: SC_instruction_mem
// Synchronous-read instruction ROM (Xilinx ROM inference template).
// 1-cycle read latency: address presented at cycle N, inst valid at cycle N+1.
// Pair with a PC delay register at the top level so (PC, inst) stay aligned.
//////////////////////////////////////////////////////////////////////////////////
module SC_instruction_mem
#(parameter  ADDR_WIDTH=10 ,parameter INST_WIDTH=32, parameter HEX_FILE="C:/Users/ec24673/project_2/tests_mem/branch_test_inst.hex")
(
    input FLUSH,
    input clk,
    input EN,
    input [ADDR_WIDTH-1:0] Addr,
    output reg [INST_WIDTH-1:0] inst
    );

    (* rom_style = "block" *)
    reg [INST_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    initial
        $readmemh(HEX_FILE, mem, 0, (2**ADDR_WIDTH)-1);

    always @(posedge clk)
        if (FLUSH) inst <= {INST_WIDTH{1'b0}};
        else if (EN)
            inst <= mem[Addr];

endmodule


							