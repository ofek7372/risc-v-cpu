`timescale 1ns / 1ps


module shiftreg
#(parameter N=8)
(   input  load,clk,nrst,sin,
    input  [N-1:0] pdata,  
    output  sout
    );
    wire [N-1:0]c;
    genvar i; 
    generate      
        for (i=0;i<N;i=i+1) begin: shiftchain
            shiftreg_bitslice   (.load(load),
                                 .sin((i==0)?sin:c[i-1]),
                                 .sout(c[i]),
                                 .clk(clk),
                                 .Pdata(pdata[i]),
                                 .nrst(nrst));
                       end

                 endgenerate
                 assign sout=c[i-1];   
                                      
                
endmodule

module shiftreg_bitslice(input load,sin,clk,nrst,Pdata , 
                        output reg sout 
                        );
     
     always @(posedge clk)
     begin 
        if (nrst==1'b0) sout<=1'b0;
        else if (load==1'b1) sout<=Pdata;
        else if (load==1'b0) sout<=sin;
     end 
     endmodule
      
          
