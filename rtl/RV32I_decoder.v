`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 14:51:39
// Design Name: 
// Module Name: RV32I_decoder
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
/*
IMMsrc : 
I = 000
B = 001
S = 011
U = 010
J = 100

ALUctrl:
ADD 0000
SUB 0001
AND 0010
OR  0011
XOR 0100
SLT 0101
SLTU 1000
SLL 0110
SRL 0111
SRA 1001

ALUsrc:
R TYPE  (000)   A<- R_A, B<-R_B
I TYPE  (001)   A<-R_A, B<-IMM
LUI     (010)   A<-0, B<-IMM
AUIPC   (011)   A<-PC,B<-IMM
JAL/JALR(100)   A<-pc,B<-4

JOP:
JAL  01
JALR 10

         
*/

module RV32I_decoder(
    input [6:0]opcode,
    input funct7_5,
    input [2:0] funct3,
    output reg [3:0] ALUctrl,
    output reg[2:0] ALUsrc,
    output reg[2:0] IMMsrc,
    output reg REGwr,MEMwr,MEMrd,MEMtoREG,bop,
    output reg [1:0] jop
    );
    
    always @(*)
        begin 
            ALUctrl=4'b0000;
            ALUsrc= 3'b000;
            IMMsrc= 3'b000;
            REGwr=1'b0;
            MEMwr =1'b0;
            MEMrd =1'b0;
            MEMtoREG=1'b0;
            bop=1'b0;
            jop=2'b00;
            
            casez (opcode)
                7'b0110011:begin//R- type
                    
                    REGwr=1'b1;
                    
                    case(funct3)
                        3'b000:ALUctrl = (funct7_5) ? 4'b0001 : 4'b0000 ; // SUB : ADD
                        3'b001:ALUctrl = 4'b0110 ; //SLL
                        3'b010:ALUctrl = 4'b0101 ; //SLT
                        3'b011:ALUctrl = 4'b1000 ; //SLTU
                        3'b100:ALUctrl = 4'b0100; //XOR
                        3'b101:ALUctrl = (funct7_5) ? 4'b1001 : 4'b0111; // SRA : SRL
                        3'b110:ALUctrl = 4'b0011 ; //OR
                        3'b111:ALUctrl = 4'b0010; //AND
                        endcase
                    end
                    
                7'b0010011:begin// I type
                    REGwr=1'b1;
                    ALUsrc=3'b001;
                    case(funct3)
                            3'b000:ALUctrl = 4'b0000; //ADDI
                            3'b001:ALUctrl = 4'b0110; //SLLI
                            3'b010:ALUctrl = 4'b0101;//SLTI
                            3'b011:ALUctrl = 4'b1000;//SLTIU
                            3'b100:ALUctrl = 4'b0100;//XORI
                            3'b101:ALUctrl = (funct7_5) ? 4'b1001 : 4'b0111 ;//SRAI:SRLI
                            3'b110:ALUctrl = 4'b0011;//ORI
                            3'b111:ALUctrl = 4'b0010;//ANDI
                        endcase
                   end
                
                7'b0000011:begin//load
                    REGwr=1'b1;
                    MEMrd=1'b1;
                    ALUsrc=3'b001;
                    MEMtoREG=1'b1;
                end
                
                7'b0100011:begin//store
                    ALUsrc=3'b001;
                    MEMwr=1'b1;
                    IMMsrc=3'b011; //s-type
                end
                
                7'b1100011:begin//branch
                    bop=1'b1;
                    IMMsrc=3'b001;
                    case(funct3)
                        3'b000:ALUctrl= 4'b0001;//BEQ
                        3'b001:ALUctrl= 4'b0001;//BNE
                        3'b101:ALUctrl= 4'b0101;//BGE
                        3'b100:ALUctrl= 4'b0101;//BLT
                        3'b110:ALUctrl= 4'b1000;//BLTU
                        3'b111:ALUctrl= 4'b1000;//BGEU
                    endcase
                end
                
                7'b0110111: begin //LUI
                    ALUsrc=3'b010;
                    REGwr=1'b1;
                    IMMsrc=3'b010;               
                end
                
                7'b0010111:begin//AUIPC
                    ALUsrc=3'b011;
                    REGwr=1'b1;
                    IMMsrc=3'b010;
                end
                
                7'b1101111:begin//JAL
                    ALUsrc=3'b100;
                    REGwr=1'b1;
                    IMMsrc=3'b100;
                    jop=2'b01;                   
                end
                
                7'b1100111:begin//JALR
                    ALUsrc=3'b100;
                    REGwr=1'b1;
                    jop=2'b10;
                end
                7'b0001111:;//FENCE
                7'b1110011:;//ECALL,EBREAK
               endcase
               end
endmodule
