`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 15:27:00
// Design Name: 
// Module Name: SC_data_mem_tb
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


module SC_data_mem_tb;

localparam  N=8;
localparam WIDTH=8;
localparam clk_period=10;
localparam ADDR_lines=5;

reg MEMrd;
reg MEMwr;
reg [ADDR_lines-1:0] addr;
reg [WIDTH-1:0] data_in;
reg clk ;
wire [WIDTH-1:0] data_out;

integer pass; integer fail; integer t;

reg tv_MEMrd [N-1:0];
reg tv_MEMwr [N-1:0];
reg [ADDR_lines-1:0] tv_addr [N-1:0];
reg [WIDTH-1:0] tv_data_in [N-1:0];
reg [WIDTH-1:0] oldval ;
SC_data_mem #(.WIDTH(WIDTH), .ADDR_lines(ADDR_lines)) 
                DUT(.MEMrd(MEMrd), 
                .MEMwr(MEMwr), 
                .data_in(data_in), 
                .data_out(data_out), 
                .addr(addr),
                .clk(clk));


//clock gen
initial clk=0;
always #(clk_period/2) clk=~clk;
         
task automatic check_write (input [WIDTH-1:0] in_data_in, 
                            input [ADDR_lines-1:0] in_addr,
                            input in_MEMwr);
                            begin 
                            data_in=in_data_in;
                            addr=in_addr;
                            MEMwr=in_MEMwr;
                            oldval=DUT.mem[in_addr];
                            @(posedge clk)
                            #1
                            if((in_data_in !== DUT.mem[in_addr])&&(MEMwr))
                                begin   
                                 $error("T:%0d, Fail",t);
                                 fail=fail+1;
                                end
                            else if ((~MEMwr)&& oldval !== DUT.mem[in_addr])
                                begin
                                $error("T:%0d, FAIL, MEMwr did not work",t);
                                fail=fail+1;
                                end
                            else begin
                                $display("T:%0d passed",t);
                                pass=pass+1;
                                end
                           end
                           endtask
               task automatic check_read ( 
                            input [ADDR_lines-1:0] in_addr,
                            input in_MEMrd);
                            begin 
                            addr=in_addr;
                            MEMrd=in_MEMrd;
                           
                            #1
                            if((data_out !== DUT.mem[in_addr])&& (in_MEMrd))
                                begin   
                                 $error("T:%0d, Fail",t);
                                 fail=fail+1;
                                end
                            else if ((~MEMrd)&& data_out != 'b0)
                                begin
                                $error("t:%0d, fail, MEMrd didnot work",t);
                                fail=fail+1;
                                end
                            else begin
                                $display("T:%0d passed",t);
                                pass=pass+1;
                                end
                           end
                           endtask  
           initial
            begin
                fail=0;
                pass=0;
                t=0;
                
                // Write tests
tv_addr[0]=5'd0;  tv_data_in[0]=8'hF0; tv_MEMwr[0]=1'b1; tv_MEMrd[0]=1'b0;
tv_addr[1]=5'd3;  tv_data_in[1]=8'h33; tv_MEMwr[1]=1'b1; tv_MEMrd[1]=1'b0;
tv_addr[2]=5'd31; tv_data_in[2]=8'hFF; tv_MEMwr[2]=1'b1; tv_MEMrd[2]=1'b0;
// MEMwr disabled — write should not happen (addr 3 should still hold 0x33)
tv_addr[3]=5'd3;  tv_data_in[3]=8'hAA; tv_MEMwr[3]=1'b0; tv_MEMrd[3]=1'b0;
// Read tests
tv_addr[4]=5'd0;  tv_data_in[4]=8'h00; tv_MEMwr[4]=1'b0; tv_MEMrd[4]=1'b1; // expect 0xF0
tv_addr[5]=5'd3;  tv_data_in[5]=8'h00; tv_MEMwr[5]=1'b0; tv_MEMrd[5]=1'b1; // expect 0x33 not 0xAA
tv_addr[6]=5'd31; tv_data_in[6]=8'h00; tv_MEMwr[6]=1'b0; tv_MEMrd[6]=1'b1; // expect 0xFF
// MEMrd disabled — data_out should be 0
tv_addr[7]=5'd0;  tv_data_in[7]=8'h00; tv_MEMwr[7]=1'b0; tv_MEMrd[7]=1'b0; // expect 0x00

for (t=0;t<4;t=t+1)
    check_write(tv_data_in[t], tv_addr[t],tv_MEMwr[t]);
    
for(t=4;t<8;t=t+1)
    check_read(tv_addr[t], tv_MEMrd[t]);
    
    $display("fail:%0d, pass:%0d",fail,pass);
    $finish;
    end
     
                
                        
                                          
endmodule
