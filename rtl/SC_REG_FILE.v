`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 15:26:32
// Design Name: 
// Module Name: SC_REG_FILE
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


module SC_REG_FILE
#(parameter REG_WIDTH=32, parameter ADDR_LINES=5)
(
input [ADDR_LINES-1:0] RS1,RS2,RD,
input REGwr,clk,
input [REG_WIDTH-1:0] data_in,
output[REG_WIDTH-1:0] R_A, R_B
    );
reg [REG_WIDTH-1:0] mem [(2**ADDR_LINES)-1:0];

always @(posedge clk) begin
if (REGwr && RD !=0) mem[RD] <= data_in;
if (REGwr &(RD==5'd0)) mem[RD]<='d0;
end

assign R_A = (RS1!=0)? mem[RS1]:'d0;
assign R_B = (RS2!=0)? mem[RS2]:'d0;

integer i;
initial begin
    for (i=0; i<2**ADDR_LINES; i=i+1)
        mem[i] = 0;
end

endmodule
