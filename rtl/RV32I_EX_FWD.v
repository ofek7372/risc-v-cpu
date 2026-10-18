`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2026 14:41:12
// Design Name: 
// Module Name: RV32I_EX_FWD
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


module RV32I_EX_FWD #(parameter WIDTH=32)(
    input [4:0] EX_RS1,EX_RS2,MEM_RD,WB_RD,
    input MEM_REGwr,WB_REGwr,
    input [WIDTH-1:0] MEM_WBdata,WB_WBdata,EX_R_A,EX_R_B,
    output reg [WIDTH-1:0] A_FWD,B_FWD
    );
    
    
    always@(*)
        begin
            //channel A
            if ((EX_RS1 != 'b0) & (EX_RS1 == MEM_RD) & MEM_REGwr )
                A_FWD = MEM_WBdata;
            else if ((EX_RS1 != 'b0)& (EX_RS1 == WB_RD) & WB_REGwr )
                A_FWD =WB_WBdata;
            else
                A_FWD = EX_R_A;
            
              //channel B
            if ((EX_RS2 != 'b0) & (EX_RS2 == MEM_RD) & MEM_REGwr )
                B_FWD = MEM_WBdata;
            else if ((EX_RS2 != 'b0)& (EX_RS2 == WB_RD) & WB_REGwr )
                B_FWD =WB_WBdata;
            else
                B_FWD = EX_R_B;
                
       end
endmodule
