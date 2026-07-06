`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 11:53:23
// Design Name: 
// Module Name: SC_main_decoder
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


module SC_main_decoder
    (
    input [6:0]oppcode,
    input [2:0]funct3,
    output reg [1:0] ALUop, IMMsrc,Bop,
    output reg ALUsrc,REGwr,MEMwr,MEMrd,MEMtoREG
    );
    
    always @(*)
        case(oppcode)
            7'b0110011:// R-type
                begin
                    ALUop = 2'b00;
                    IMMsrc = 2'b01;//hits default
                    Bop = 2'b00;
                    ALUsrc=1'b0;
                    REGwr=1'b1;
                    MEMrd=1'b0;
                    MEMwr=1'b0;
                    MEMtoREG=1'b0;
                    end
                    
           7'b0010011: //I-type
                 begin
                     ALUop = 2'b01;
                    IMMsrc = 2'b00;//hits I_type imm
                    Bop = 2'b00;
                    ALUsrc=1'b1;
                    REGwr=1'b1;
                    MEMrd=1'b0;
                    MEMwr=1'b0;
                    MEMtoREG=1'b0;
                    end
          7'b0000011: begin //begin//load
                    ALUop = 2'b10;
                    IMMsrc = 2'b00;//hits I_type
                    Bop = 2'b00;
                    ALUsrc=1'b1;
                    REGwr=1'b1;
                    MEMrd=1'b1;
                    MEMwr=1'b0;
                    MEMtoREG=1'b1;
                    end
         7'b0100011: begin //store
                     ALUop = 2'b10;
                    IMMsrc = 2'b11;//hits S_type
                    Bop = 2'b00;
                    ALUsrc=1'b1;
                    REGwr=1'b0;
                    MEMrd=1'b0;
                    MEMwr=1'b1;
                    MEMtoREG=1'b0;
                    end
                    
        7'b1100011: //Branch
            begin
                if(funct3 == 3'b000)//BEQ
                    begin
                    ALUop = 2'b11;
                    IMMsrc = 2'b01;//hits B_type
                    Bop = 2'b10;
                    ALUsrc=1'b0;
                    REGwr=1'b0;
                    MEMrd=1'b0;
                    MEMwr=1'b0;
                    MEMtoREG=1'b0;
                    end
                    
                else if(funct3 == 3'b001)//BNE
                    begin
                    ALUop = 2'b11;
                    IMMsrc = 2'b01;//hits B_type
                    Bop = 2'b01;
                    ALUsrc=1'b0;
                    REGwr=1'b0;
                    MEMrd=1'b0;
                    MEMwr=1'b0;
                    MEMtoREG=1'b0;
                    end
                
               else 
                begin
                ALUop = 2'b00;
                    IMMsrc = 2'b00;//hits S_type
                    Bop = 2'b00;
                    ALUsrc=1'b0;
                    REGwr=1'b0;
                    MEMrd=1'b0;
                    MEMwr=1'b0;
                    MEMtoREG=1'b0;
                end
                end
            default: 
                  begin
                    ALUop = 2'b00;
                    IMMsrc = 2'b00;
                    Bop = 2'b00;
                    ALUsrc=1'b0;
                    REGwr=1'b0;
                    MEMrd=1'b0;
                    MEMwr=1'b0;
                    MEMtoREG=1'b0;
                    end
                endcase
endmodule
