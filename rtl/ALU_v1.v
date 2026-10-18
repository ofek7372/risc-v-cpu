`timescale 1ns / 1ps


module ALU_v1
#(parameter WIDTH=32)

( input [WIDTH-1:0] a,b,
  input [3:0] alu_ctrl,
  output reg [WIDTH-1:0] Y,
  output reg cout_borrow,
  output zero//, negative 


    );
 //add,sub,and,or,xor,slt,sltu,sll,srl,sra   
 always @(*) begin
    Y= {WIDTH{1'b0}};
    cout_borrow= 1'b0;
    case (alu_ctrl)
    
    4'b1001:Y= $signed(a) >>> b[$clog2(WIDTH)-1:0];//SRA
    4'b1000:Y= {{(WIDTH-1){1'b0}},(a < b)};//SLTU
    4'b0111: Y= a>>b[$clog2(WIDTH)-1:0]; //logical shift right (insert zero)
    4'b0110: Y= a<<(b[$clog2(WIDTH)-1:0]);// logical shift left SLL (insert zero)
    4'b0101: Y={{(WIDTH-1){1'b0}},( $signed(a) < $signed(b))}; //slt
    4'b0100: Y=a^b;// xor
    4'b0011: Y=a|b;//or
    4'b0010: Y=a&b;// and
    4'b0001: {cout_borrow,Y}= a - b; //subb
    4'b0000: {cout_borrow,Y}= a + b; //add
    default: Y = 'b0;
    
    endcase
       end
  assign zero=~|Y;
  //assign negative=Y[WIDTH-1];
endmodule
