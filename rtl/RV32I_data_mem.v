`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.08.2026 11:25:41
// Design Name: 
// Module Name: RV32I_data_mem
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


module RV32I_data_mem #(parameter WIDTH=32, parameter data_addr_width=10)(
    input clk,MEMwr,MEMrd,
    input [3:0] byte_enable,
    input [data_addr_width-1:0] addr,
    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
    );
    
    reg [WIDTH-1:0] mem [0:(2**data_addr_width)-1];
    
    //store
    always @(posedge clk)
        begin
           if(MEMwr) begin 
            if (byte_enable[0]) mem [addr][7:0] <= data_in[7:0];
            if (byte_enable[1]) mem [addr][15:8]<= data_in[15:8];
            if (byte_enable[2]) mem [addr][23:16]<= data_in[23:16];
            if (byte_enable[3]) mem [addr][31:24]<= data_in[31:24];
        end
        end

assign data_out = (MEMrd) ? mem[addr] : 32'b0;
        
            
endmodule
