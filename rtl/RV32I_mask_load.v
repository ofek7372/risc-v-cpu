`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:53:29
// Design Name: 
// Module Name: RV32I_mask_load
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


module RV32I_load_unit #(parameter WIDTH=32)(
    input [2:0] MEM_funct3,
    input [1:0] MEM_ALUresult,
    input [WIDTH-1:0] mem_data_out,
    output reg [WIDTH-1:0] load_data

    );
    
    localparam lb = 3'b000;
    localparam lh = 3'b001;
    localparam lw = 3'b010;
    localparam lbu= 3'b100;
    localparam lhu= 3'b101;
    
    reg [WIDTH-1:0] tmp;
    
    //adjust and place
    always @(*)
        begin
            tmp=32'b0;
            case(MEM_funct3)
                lbu, lb: begin
                            case(MEM_ALUresult)
                                2'b00: tmp[7:0] = mem_data_out [7:0];
                                2'b01: tmp[7:0] = mem_data_out [15:8];
                                2'b10: tmp[7:0] = mem_data_out [23:16];
                                2'b11: tmp[7:0] = mem_data_out [31:24];
                             endcase
                         end
                lh, lhu: begin 
                            case(MEM_ALUresult[1])
                            1'b0: tmp [15:0] = mem_data_out [15:0];
                            1'b1: tmp [15:0] = mem_data_out [31:16];
                            endcase
                         end
                lw: tmp = mem_data_out;
            endcase   
        end     
    //sign_extend
    
    always @(*)
        begin 
            load_data= 'b0;
            case(MEM_funct3)
                lb:load_data={{24{tmp[7]}},tmp[7:0]};
                lh:load_data={{16{tmp[15]}},tmp[15:0]};
                lw:load_data=tmp;
                lbu:load_data={24'b0,tmp[7:0]};
                lhu:load_data={16'b0,tmp[15:0]};
            endcase
            end
endmodule
