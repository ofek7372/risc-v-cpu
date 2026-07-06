`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 15:58:30
// Design Name: 
// Module Name: SC_REG_FILE_tb
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


module SC_REG_FILE_tb;

localparam ADDR_LINES=5;
localparam REG_WIDTH=32;
localparam clk_period=10;
localparam N=10;

reg [REG_WIDTH-1:0] data_in;
reg [ADDR_LINES-1:0] RS1,RS2,RD;
reg REGwr,clk;
wire [REG_WIDTH-1:0] R_A ,R_B;
reg [REG_WIDTH-1:0] old_val;
//DUT_connection
SC_REG_FILE DUT(.RS1(RS1),
                .RS2(RS2),
                .RD(RD),
                .data_in(data_in),
                .REGwr(REGwr),
                .R_A(R_A),
                .R_B(R_B),
                .clk(clk)
                );

//clock generation
initial clk=0;
always #(clk_period/2) clk <= ~clk;

integer pass_count;
integer fail_count;
integer t;

task automatic write_reg (input [ADDR_LINES-1:0]in_RD , input[REG_WIDTH-1:0]in_data_in);
    begin
    REGwr=1'b1 ; RD=in_RD; data_in=in_data_in;
    @(posedge clk)
    #1
    
    if (DUT.mem[RD]!== data_in && (RD!== 1'd0)) begin
        $error("T:%0d faild write, at register :%0d value:%0h expected: %0h", t,RD,DUT.mem[RD],data_in);
        fail_count= fail_count+1;
        end
    else if(DUT.mem[RD]=='b0 && RD==5'b0)
        begin
            $display("T:%0d cant write to reg0",t);
                pass_count=pass_count+1;
        end
    else begin
        $display("T:%0d, wrote successfully, data:%0h to reg:%0d",t,data_in,RD);
        pass_count=pass_count+1;
        end
        end
        endtask
 
task automatic read_reg (input [ADDR_LINES-1:0] in_RS1,in_RS2);
    begin
        RS1=in_RS1; RS2=in_RS2;
        #1
        if ((R_A !== DUT.mem[RS1])|(R_B !== DUT.mem[RS2]))
            begin
                $error("T:%0d fail to read: R_A:%0h, R_B:%0h expected: R_A:%0h, R_B:%0h",t,R_A,R_B, DUT.mem[RS1],DUT.mem[RS2]);
                fail_count=fail_count+1;
                end
                else
                    begin
                    $display("T:%0d read successfully R_A:%0h,R_B: %0h \n",t,R_A,R_B);
                    pass_count=pass_count+1;
                    end
     end
     endtask
     
task automatic RAW (input [ADDR_LINES-1:0] in_RS1,in_RS2,
                    input [ADDR_LINES-1:0]in_RD ,
                    input[REG_WIDTH-1:0]in_data_in 
                    );
                    begin
                    old_val = DUT.mem[RD];
                    #1
                    write_reg (in_RD , in_data_in);
                    #1
                    read_reg (in_RS1 ,in_RS2);
                    if (in_RS1 == in_RD)
                        begin   
                            if (R_A !== in_data_in)
                                begin
                                    $error("T:%0d, RAW faild data_in:%0h, old_val:%0h, R_A:%0d",t,in_data_in,old_val,R_A);
                                    fail_count= fail_count+1;
                                end
                            else if (R_A == in_data_in) begin 
                             $display("T:%0d passed RAW",t);
                             pass_count=pass_count+1;
                             end
                         end
                  else if(in_RS2 == in_RD)
                     begin   
                            if (R_B !== in_data_in)
                                begin
                                    $error("T:%0d, RAW faild data_in:%0h, old_val:%0h, R_B:%0d",t,in_data_in,old_val,R_B);
                                    fail_count= fail_count+1;
                                end
                            else if (R_B == in_data_in) begin 
                             $display("T:%0d passed RAW",t);
                             pass_count=pass_count+1;
                             end
                         end
    end
    endtask
    
reg [ADDR_LINES-1:0] tv_RS1 [N-1:0];
reg [ADDR_LINES-1:0] tv_RS2 [N-1:0];
reg [ADDR_LINES-1:0] tv_RD [N-1:0];
reg [REG_WIDTH-1:0] tv_data [N-1:0];



initial begin

fail_count=0;
pass_count=0;
t=0;
//write tests 
tv_RS1[0]=5'd0 ; tv_RS2[0]= 5'd0 ; tv_RD[0]=5'd0 ; tv_data[0]=32'hFFFAAAAA;
tv_RS1[1]=5'd0 ; tv_RS2[1]= 5'd0 ; tv_RD[1]=5'd1 ; tv_data[1]=32'h11111111;
tv_RS1[2]=5'd0 ; tv_RS2[2]= 5'd0 ; tv_RD[2]=5'd2 ; tv_data[2]=32'h22222222;
tv_RS1[3]=5'd0 ; tv_RS2[3]= 5'd0 ; tv_RD[3]=5'd3 ; tv_data[3]=32'h33333333;
//read tests
tv_RS1[4]=5'd1 ; tv_RS2[4]= 5'd0 ; tv_RD[4]=5'd0 ; tv_data[4]=32'hFFFAAAAA;
tv_RS1[5]=5'd2 ; tv_RS2[5]= 5'd0 ; tv_RD[5]=5'd0 ; tv_data[5]=32'h11111111;
tv_RS1[6]=5'd0 ; tv_RS2[6]= 5'd0 ; tv_RD[6]=5'd0 ; tv_data[6]=32'h22222222;
tv_RS1[7]=5'd0 ; tv_RS2[7]= 5'd3 ; tv_RD[7]=5'd0 ; tv_data[7]=32'h33333333;

//RAW tests
tv_RS1[8]=5'd5 ; tv_RS2[8]= 5'd0 ; tv_RD[8]=5'd5 ; tv_data[8]=32'h5;   
tv_RS1[9]=5'd2 ; tv_RS2[9]= 5'd6 ; tv_RD[9]=5'd6 ; tv_data[9]=32'h6;     

for(t=0;t<4;t=t+1) begin
    write_reg(tv_RD[t],tv_data[t]);
    end
for(t=4; t<8;t=t+1) begin
    read_reg(tv_RS1[t], tv_RS2[t]);
        end
for (t=8;t<10;t=t+1)
    RAW(tv_RS1[t],tv_RS2[t],tv_RD[t],tv_data[t]);
    
    $display ("PASSED:%0d, FAILED:%0d",pass_count,fail_count);
    $finish;
    end
endmodule
