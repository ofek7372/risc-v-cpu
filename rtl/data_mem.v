`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.08.2026 14:32:01
// Design Name: 
// Module Name: data_mem
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


module data_mem #(
//  Xilinx Single Port Byte-Write Write First RAM
  //  This code implements a parameterizable single-port byte-write write-first memory where when data
  //  is written to the memory, the output reflects the new memory contents.
  //  If a reset or enable is not necessary, it may be tied off or removed from the code.
  //  Modify the parameters for the desired RAM characteristics.
  parameter NB_COL = 4,                       // Specify number of columns (number of bytes)
  parameter COL_WIDTH = 8,                  // Specify column width (byte width, typically 8 or 9)
  parameter RAM_DEPTH = 1024,                  // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "LOW_LATENCY", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = "")(                       // Specify name/location of RAM initialization file if using one (leave blank if not)
  input [clogb2(RAM_DEPTH-1)-1:0] addr,  // Address bus, width determined from RAM_DEPTH
  input [(NB_COL*COL_WIDTH)-1:0] data_in,  // RAM input data
  input clk,                           // Clock
  input [NB_COL-1:0] byte_ena,               // Byte-write enable
  //<wire_or_reg> <ena>;                            // RAM Enable, for additional power savings, disable port when not in use
 // <wire_or_reg> <rsta>;                           // Output reset (does not affect memory contents)
  input MEMrd,MEMwr,
  output [(NB_COL*COL_WIDTH)-1:0] data_out);          // RAM output data
  reg [(NB_COL*COL_WIDTH)-1:0] ram_name [RAM_DEPTH-1:0];
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data = {(NB_COL*COL_WIDTH){1'b0}};
  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, ram_name, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          ram_name[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
    end
  endgenerate
  generate
  genvar i;
     for (i = 0; i < NB_COL; i = i+1) begin: byte_write
       always @(posedge clk)
       if(MEMwr)begin
           if (byte_ena[i]) begin
             ram_name[addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= data_in[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             ram_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= data_in[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
          end end else
             ram_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= ram_name[addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
      end
  endgenerate
  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign data_out = ram_data;
    end else begin: output_register
      // The following is a 2 clock cycle read latency with improve clock-to-out timing
      reg [(NB_COL*COL_WIDTH)-1:0] douta_reg = {(NB_COL*COL_WIDTH){1'b0}};
      always @(posedge clk)
        if (!MEMrd)
          douta_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        else if (MEMrd)
          douta_reg <= ram_data;
      assign data_out = douta_reg;
    end
  endgenerate
  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule
