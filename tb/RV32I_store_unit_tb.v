`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_store_unite_tb
// Self-checking testbench for the store lane/mask unit.
//   SB(000): byte in lane[offset],  enable = 1<<offset
//   SH(001): half in half[offset1], enable = offset[1]?1100:0011
//   SW(010): full word,             enable = 1111
//   non-store: enable = 0000
// The KEY property: the enabled lane(s) and the positioned data agree.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_store_unite_tb;

    localparam WIDTH = 32;
    localparam sb=3'b000, sh=3'b001, sw=3'b010;

    reg  [2:0] MEM_funct3;
    reg  [1:0] MEM_ALUresult;
    reg  [WIDTH-1:0] MEM_B_FWD;
    wire [3:0] byte_enable;
    wire [WIDTH-1:0] MEM_data_in;

    integer pass, fail, t, i;

    RV32I_store_unite #(.WIDTH(WIDTH)) DUT (
        .MEM_funct3(MEM_funct3), .byte_enable(byte_enable),
        .MEM_ALUresult(MEM_ALUresult), .MEM_B_FWD(MEM_B_FWD),
        .MEM_data_in(MEM_data_in)
    );

    // reference model: returns {enable, data}
    task automatic expected(
        input [2:0] f3, input [1:0] off, input [WIDTH-1:0] bf,
        output [3:0] e_en, output [WIDTH-1:0] e_data
    );
        begin
            e_en = 4'b0000;
            e_data = 32'b0;
            case (f3)
                sb: begin
                    e_en = (4'b0001 << off);
                    case (off)
                        2'b00: e_data[7:0]   = bf[7:0];
                        2'b01: e_data[15:8]  = bf[7:0];
                        2'b10: e_data[23:16] = bf[7:0];
                        2'b11: e_data[31:24] = bf[7:0];
                    endcase
                end
                sh: begin
                    e_en = off[1] ? 4'b1100 : 4'b0011;
                    if (off[1]) e_data[31:16] = bf[15:0];
                    else        e_data[15:0]  = bf[15:0];
                end
                sw: begin
                    e_en = 4'b1111;
                    e_data = bf;
                end
                default: begin e_en = 4'b0000; e_data = 32'b0; end
            endcase
        end
    endtask

    reg [3:0] e_en; reg [WIDTH-1:0] e_data;

    task automatic check(input [8*10-1:0] name);
        begin
            #5;
            expected(MEM_funct3, MEM_ALUresult, MEM_B_FWD, e_en, e_data);
            // For store, only the ENABLED lanes of data matter; but this module
            // low-aligns/zeros unenabled lanes, so we check full data + enable.
            if (byte_enable === e_en && MEM_data_in === e_data) begin
                $display("T%0d PASS: %0s en=%b data=%h", t, name, byte_enable, MEM_data_in);
                pass=pass+1;
            end else begin
                $error("T%0d FAIL: %0s f3=%b off=%b B=%h | en=%b(exp %b) data=%h(exp %h)",
                        t, name, MEM_funct3, MEM_ALUresult, MEM_B_FWD,
                        byte_enable, e_en, MEM_data_in, e_data);
                fail=fail+1;
            end
            t=t+1;
        end
    endtask

    integer off_i;
    initial begin
        pass=0; fail=0; t=0;
        MEM_B_FWD = 32'hDDCCBBAA;   // distinctive: low byte AA, low half BBAA

        // ===== SB at every offset: data lane and enable must agree =====
        MEM_funct3=sb;
        MEM_ALUresult=2'b00; check("SB_off0");   // en 0001, data ......AA
        MEM_ALUresult=2'b01; check("SB_off1");   // en 0010, data ....AA..
        MEM_ALUresult=2'b10; check("SB_off2");   // en 0100, data ..AA....
        MEM_ALUresult=2'b11; check("SB_off3");   // en 1000, data AA......

        // ===== SH at aligned offsets 0 and 2 =====
        MEM_funct3=sh;
        MEM_ALUresult=2'b00; check("SH_off0");   // en 0011, data ....BBAA
        MEM_ALUresult=2'b10; check("SH_off2");   // en 1100, data BBAA....

        // ===== SW =====
        MEM_funct3=sw;
        MEM_ALUresult=2'b00; check("SW");        // en 1111, data DDCCBBAA

        // ===== non-store funct3: enable must be 0 =====
        MEM_funct3=3'b111; MEM_ALUresult=2'b00; check("nonstore");

        // ===== random stress (all offsets, various data) =====
        for (i=0;i<200;i=i+1) begin
            MEM_B_FWD=$random;
            for (off_i=0; off_i<4; off_i=off_i+1) begin
                MEM_ALUresult = off_i[1:0];
                MEM_funct3=sb; check("RND_SB");
                MEM_funct3=sh; check("RND_SH");
                MEM_funct3=sw; check("RND_SW");
            end
        end

        $display("=== STORE RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule