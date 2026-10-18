`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:55:10
// Design Name: 
// Module Name: RV32I_mask_store
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


module RV32I_store_unite #(parameter WIDTH=32) (
    input [2:0] MEM_funct3,
    output reg [3:0] byte_enable,
    input [1:0] MEM_ALUresult,
    input [WIDTH-1:0] MEM_B_FWD,
    output [WIDTH-1:0] MEM_data_in 

    );
    localparam sb = 3'b000;
    localparam sh = 3'b001;
    localparam sw = 3'b010;
    
    reg [7:0] ln0,ln1,ln2,ln3;
    wire [7:0] sbyte;
    assign sbyte = MEM_B_FWD[7:0];
    wire [15:0] shalf;
    assign shalf = MEM_B_FWD[15:0];
    always @(*)
        begin
            byte_enable=4'b0000;
            case(MEM_funct3)
                sb:begin 
                    case(MEM_ALUresult)
                        2'b00: byte_enable=4'b0001;
                        2'b01: byte_enable=4'b0010;
                        2'b10: byte_enable=4'b0100;
                        2'b11: byte_enable=4'b1000;
                         endcase
                    end
                sh: begin
                    case(MEM_ALUresult[1])
                        1'b0:byte_enable=4'b0011;
                        1'b1:byte_enable=4'b1100;
                    endcase
                    end
                    
                sw: byte_enable=4'b1111;
                
                endcase
       end
    
    always @(*)
        begin 
           {ln3,ln2,ln1,ln0}=32'b0; 
           if(MEM_funct3 == sb) 
                case(MEM_ALUresult)
                    2'b00: ln0 = sbyte;
                    2'b01: ln1 = sbyte;
                    2'b10: ln2 = sbyte;
                    2'b11: ln3 = sbyte;
                    default:{ln3,ln2,ln1,ln0}=32'b0;
                 endcase
             else if (MEM_funct3 == sh)
                case(MEM_ALUresult[1])
                    1'b0: {ln1,ln0}=shalf;
                    1'b1: {ln3,ln2}=shalf;
                    default:{ln3,ln2,ln1,ln0}=32'b0 ;
                endcase
             else if (MEM_funct3 == sw)
                {ln3,ln2,ln1,ln0} = MEM_B_FWD;
                
         end
 assign MEM_data_in = {ln3,ln2,ln1,ln0};                
endmodule
