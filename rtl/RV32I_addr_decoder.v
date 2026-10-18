`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.08.2026 12:11:27
// Design Name: 
// Module Name: RV32I_addr_decoder
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


module RV32I_addr_decoder #( parameter data_base_address=1000, parameter WIDTH=32, parameter data_addr_width=10)(

    input[WIDTH-1:0] ALUresult,
    output [data_addr_width-1:0] addr 

    );
    wire [WIDTH-1:0]byte_addr;
    assign byte_addr = ALUresult-data_base_address;
    assign addr = byte_addr >> 2;
    
endmodule
