`timescale 1ns / 1ps


module ALU_v1
#(parameter WIDTH=8)

( input [WIDTH-1:0] a,b,
  input [2:0] alu_ctrl,
  output reg [WIDTH-1:0] Y,
  output reg cout_borrow,
  output zero, negative 


    );
    
 always @(*) begin
    Y= {WIDTH{1'b0}};
    cout_borrow= 1'b0;
    case (alu_ctrl)
    3'b111: Y={1'b0,a[WIDTH-2:0]}; //logical shift right (insert zero)
    3'b110: Y={a[WIDTH-1:1],1'b0};// logical shift left SLL (insert zero)
    3'b101: Y={{(WIDTH-1){1'b0}},(a<b)}; 
    3'b100: Y=a^b;// xor
    3'b011: Y=a|b;//or
    3'b010: Y=a&b;// and
    3'b001: {cout_borrow,Y}= a - b; //subb
    3'b000: {cout_borrow,Y}= a + b; //add
    
    endcase
       end
  assign zero=~|Y;
  assign negative=Y[WIDTH-1];
endmodule
