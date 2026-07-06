`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 15:13:51
// Design Name: 
// Module Name: SC_instruction_mem
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


module SC_instruction_mem
#(parameter  ADDR_WIDTH=7 ,parameter INST_WIDTH=32)
(
    input [ADDR_WIDTH-1:0]Addr, 
    output[INST_WIDTH-1:0]inst
    );
    
  reg [7:0] mem [2**(ADDR_WIDTH)-1:0];
  initial begin 
  $readmemh("C:/Users/ec24673/project_2/mem/imem.hex", mem);
  end
  
  assign inst={mem[Addr+3],mem[Addr+2],mem[Addr+1],mem[Addr]};
    
endmodule
