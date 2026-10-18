`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_PC_delay
// Holds PC for one extra cycle so it stays paired with the instruction word,
// which now arrives one cycle after the address was presented (synchronous
// instruction memory read). Same EN/FLUSH/nRST semantics as your other
// pipeline registers, for consistency.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_PC_delay #(parameter WIDTH=32)(
    input clk, EN, nRST, FLUSH,
    input [WIDTH-1:0] PC_in,
    output reg [WIDTH-1:0] PC_out
    );

    always @(posedge clk) begin
        if (nRST == 1'b0)
            PC_out <= {WIDTH{1'b0}};
        else if (FLUSH == 1'b1)
            PC_out <= {WIDTH{1'b0}};
        else if (EN == 1'b1)
            PC_out <= PC_in;
    end
endmodule