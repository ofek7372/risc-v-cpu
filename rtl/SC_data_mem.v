`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 15:17:08
// Design Name: 
// Module Name: SC_data_mem
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


module SC_data_mem
#(parameter WIDTH=32, ADDR_lines=5)
(   
    input  [WIDTH-1:0] data_in,
    output  [WIDTH-1:0] data_out,
    input MEMrd,MEMwr,clk,
    input [ADDR_lines-1:0] addr
    );
    
reg [7:0] mem [(2**ADDR_lines)-1:0];

always @(posedge clk)
    if(MEMwr)
        {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]}<= data_in;
assign data_out = (MEMrd)? {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]}: 'b0;
 
endmodule
