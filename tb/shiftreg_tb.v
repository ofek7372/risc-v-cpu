`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2026 06:36:10
// Design Name: 
// Module Name: shiftreg_tb
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


module shiftreg_tb;

localparam N=8;
localparam CLOCK_PERIOD=10;

reg clk, load,nrst,sin;
reg [7:0] pdata;
wire sout;

initial clk=0;
always #((CLOCK_PERIOD)/2) clk=~clk; //clock signal 

shiftreg #(.N(N)) DUT(.load(load),.pdata(pdata),.sin(sin),.sout(sout),.nrst(nrst),.clk(clk));
integer i,j;
initial begin 
//t1- parallal load check
    nrst=0;

   @(posedge clk)#1;
   @(posedge clk)#1;
    nrst=1;
    sin=1'b0;
    pdata= 8'hff;
    load=1'b1;
    @(posedge clk)#1;
    load=1'b0;
    
    
    for (i=0;i<8;i=i+1)
     begin
        @(posedge clk);
        #1;

        if(sout!==1'b1) 
            $error("parallal load fail i[%0d]=%0d",(7-i),sout);
        else 
            $display("parallal load pass");
    end

//t2-reset check 
   sin=1'b0;
    pdata= 8'hff;
    load=1'b1;
    @(posedge clk);#1;
    load=1'b0;
    nrst=0;
        
    for (i=0;i<8;i=i+1)
     begin
        @(posedge clk);
        #1;

        if(sout!==1'b0) 
            $error("parallal load fail i[%0d]=%0d",(7-i),sout);
        else 
            $display("parallal load pass");
    end

//t3-test serial load 

    for (i=0;i<8;i=i+1)
        begin
            if(i>=4)  sin=1'b1;
            else sin=1'b0; 
             @(posedge clk)#1;
         end   
    for(j=0;j<4;j=j+1)
        begin
         @(posedge clk);
         if (sout!==1'b0) $error("serial load part 1 fail");
         else $display("serial load part 1 pass");
         end
         
            for(j=0;j<4;j=j+1)
        begin
         @(posedge clk);
         if (sout!==1'b1) $error("serial load part 2 fail");
         else $display("serial load part 2 pass");
         end

          
        
end
$finish;

endmodule
