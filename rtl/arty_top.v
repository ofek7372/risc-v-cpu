module arty_top (
    input        CLK100MHZ,
    input  [0:0] btn,
    input  [0:0] sw,
    output [3:0] led
);
    wire clk50, locked;
    clk_wiz_0 u_clk (.clk_in1(CLK100MHZ), .clk_out1(clk50), .locked(locked));

    reg [1:0] rst_sync = 2'b00;
    always @(posedge clk50) rst_sync <= {rst_sync[0], ~btn[0] & locked};
    wire nRST = rst_sync[1];

    wire [31:0] pc, wb_data;
    wire [4:0]  wb_rd;
    wire        wb_we;

    RV32I_top cpu (.clk(clk50), .EN(sw[0]), .nRST(nRST),
                   .dbg_PC(pc), .dbg_WBdata(wb_data),
                   .dbg_WBrd(wb_rd), .dbg_WBregwr(wb_we));

    reg [3:0] led_r = 4'b0;
    always @(posedge clk50)
        if (!nRST)                        led_r <= 4'b0;
        else if (wb_we && wb_rd == 5'd10) led_r <= wb_data[3:0];
    assign led = led_r;
endmodule