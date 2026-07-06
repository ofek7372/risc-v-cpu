`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 08:28:07
// Design Name: 
// Module Name: SC_top_tb
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


module SC_top_tb;
localparam clk_period=10;

reg clk,nRST,EN;

initial clk=0;
always #(clk_period/2) clk=~clk;

SC_top_module DUT(.clk(clk), .nRST(nRST), .EN(EN));

initial
    begin 
        EN=1;
        nRST=1'b1;
        #1
        nRST=1'b0;
        #clk_period;
        #clk_period;
        nRST=1'b1;
        while(DUT.data_mem.mem[30]!== 8'hB8 && DUT.data_mem.mem[31] !== 8'h02 && DUT.data_mem.mem[32] !== 8'h00 && DUT.data_mem.mem[33]!==8'h00 )begin
         @(posedge clk);
         end
        $finish;
end
endmodule
