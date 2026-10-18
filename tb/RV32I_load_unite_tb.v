`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_load_unit_tb
// Self-checking testbench for the load extract+extend unit.
//   LB(000):  sign-extend byte  at lane[offset]
//   LH(001):  sign-extend half  at half[offset1]
//   LW(010):  full word
//   LBU(100): zero-extend byte
//   LHU(101): zero-extend half
// Key checks: correct lane by offset, and sign vs zero extension (esp. halfword).
//////////////////////////////////////////////////////////////////////////////////
module RV32I_load_unit_tb;

    localparam WIDTH = 32;
    localparam lb=3'b000, lh=3'b001, lw=3'b010, lbu=3'b100, lhu=3'b101;

    reg  [2:0] MEM_funct3;
    reg  [1:0] MEM_ALUresult;
    reg  [WIDTH-1:0] mem_data_out;
    wire [WIDTH-1:0] load_data;

    integer pass, fail, t, i;

    RV32I_load_unit #(.WIDTH(WIDTH)) DUT (
        .MEM_funct3(MEM_funct3), .MEM_ALUresult(MEM_ALUresult),
        .mem_data_out(mem_data_out), .load_data(load_data)
    );

    // reference model
    function [WIDTH-1:0] expload(input [2:0] f3, input [1:0] off, input [WIDTH-1:0] w);
        reg [7:0] the_byte;
        reg [15:0] the_half;
        begin
            case (off)
                2'b00: the_byte = w[7:0];
                2'b01: the_byte = w[15:8];
                2'b10: the_byte = w[23:16];
                2'b11: the_byte = w[31:24];
            endcase
            the_half = off[1] ? w[31:16] : w[15:0];
            case (f3)
                lb:  expload = {{24{the_byte[7]}},  the_byte};
                lbu: expload = {24'b0,              the_byte};
                lh:  expload = {{16{the_half[15]}}, the_half};
                lhu: expload = {16'b0,              the_half};
                lw:  expload = w;
                default: expload = 32'b0;
            endcase
        end
    endfunction

    task automatic check(input [8*10-1:0] name);
        reg [WIDTH-1:0] e;
        begin
            #5;
            e = expload(MEM_funct3, MEM_ALUresult, mem_data_out);
            if (load_data === e) begin
                $display("T%0d PASS: %0s ld=%h", t, name, load_data);
                pass=pass+1;
            end else begin
                $error("T%0d FAIL: %0s f3=%b off=%b w=%h ld=%h exp=%h",
                        t, name, MEM_funct3, MEM_ALUresult, mem_data_out, load_data, e);
                fail=fail+1;
            end
            t=t+1;
        end
    endtask

    integer off_i;
    initial begin
        pass=0; fail=0; t=0;

        // word with each lane distinctive and top bits set (to test sign ext)
        mem_data_out = 32'h80FF7F01;   // lane0=01, lane1=7F, lane2=FF, lane3=80

        // ===== LB at each offset: sign extension depends on that byte's bit7 =====
        MEM_funct3=lb;
        MEM_ALUresult=2'b00; check("LB_o0");  // 01 -> +1
        MEM_ALUresult=2'b01; check("LB_o1");  // 7F -> +127
        MEM_ALUresult=2'b10; check("LB_o2");  // FF -> -1 (sign ext)
        MEM_ALUresult=2'b11; check("LB_o3");  // 80 -> -128 (sign ext)

        // ===== LBU: zero extension, same bytes =====
        MEM_funct3=lbu;
        MEM_ALUresult=2'b10; check("LBU_o2"); // FF -> 0x000000FF
        MEM_ALUresult=2'b11; check("LBU_o3"); // 80 -> 0x00000080

        // ===== LH at offset 0 and 2, with sign bit set/clear =====
        MEM_funct3=lh;
        MEM_ALUresult=2'b00; check("LH_lo");  // half=7F01 -> +ve
        MEM_ALUresult=2'b10; check("LH_hi");  // half=80FF -> -ve (sign ext -> 0xFFFF80FF)

        // ===== LHU: zero extension =====
        MEM_funct3=lhu;
        MEM_ALUresult=2'b00; check("LHU_lo"); // 0x00007F01
        MEM_ALUresult=2'b10; check("LHU_hi"); // 0x000080FF

        // ===== LW passthrough =====
        MEM_funct3=lw; MEM_ALUresult=2'b00; check("LW");

        // ===== random stress: all funct3 x all offsets x random words =====
        for (i=0;i<200;i=i+1) begin
            mem_data_out=$random;
            for (off_i=0; off_i<4; off_i=off_i+1) begin
                MEM_ALUresult=off_i[1:0];
                MEM_funct3=lb;  check("RND_LB");
                MEM_funct3=lbu; check("RND_LBU");
                MEM_funct3=lh;  check("RND_LH");
                MEM_funct3=lhu; check("RND_LHU");
                MEM_funct3=lw;  check("RND_LW");
            end
        end

        $display("=== LOAD RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule