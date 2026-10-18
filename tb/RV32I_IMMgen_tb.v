`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_IMMgen_tb
// Self-checking testbench for the immediate generator.
//
// Strategy: expected values are computed INDEPENDENTLY of the DUT's bit-slicing.
// For each type we build a full 32-bit instruction word by PLACING a known
// immediate value into the correct instruction fields (per the RISC-V spec
// layout), then check the DUT reconstructs that same immediate. This avoids the
// "expected mirrors the module" vacuous-pass trap.
//
// Port note: imm_lines is [31:7]; we drive it from inst[31:7].
//////////////////////////////////////////////////////////////////////////////////
module RV32I_IMMgen_tb;

    localparam I_type = 3'b000;
    localparam B_type = 3'b001;
    localparam S_type = 3'b011;
    localparam U_type = 3'b010;
    localparam J_type = 3'b100;

    reg  [2:0]  IMMsrc;
    reg  [31:0] inst;          // full instruction word (we slice [31:7] to DUT)
    wire [31:0] imm;

    integer pass, fail, t;

    RV32I_IMMgen DUT (
        .IMMsrc(IMMsrc),
        .imm_lines(inst[31:7]),
        .imm(imm)
    );

    // ---- field-packing helpers: place a semantic immediate into inst fields ----

    // I-type: imm[11:0] -> inst[31:20]
    task automatic pack_I(input [11:0] v);
    begin
        inst = 32'b0;
        inst[31:20] = v;
    end
    endtask

    // S-type: imm[11:5]->inst[31:25], imm[4:0]->inst[11:7]
    task automatic pack_S(input [11:0] v);
        begin
            inst = 32'b0;
            inst[31:25] = v[11:5];
            inst[11:7]  = v[4:0];
        end
    endtask

    // B-type: imm[12]->31, imm[10:5]->30:25, imm[4:1]->11:8, imm[11]->7, imm[0]=0
    task automatic pack_B(input [12:0] v); // v[0] must be 0
        begin
            inst = 32'b0;
            inst[31]    = v[12];
            inst[30:25] = v[10:5];
            inst[11:8]  = v[4:1];
            inst[7]     = v[11];
        end
    endtask

    // U-type: imm[31:12]->inst[31:12], low 12 bits are 0
    task automatic pack_U(input [19:0] hi20);
        begin
            inst = 32'b0;
            inst[31:12] = hi20;
        end
    endtask

    // J-type: imm[20]->31, imm[10:1]->30:21, imm[11]->20, imm[19:12]->19:12, imm[0]=0
    task automatic pack_J(input [20:0] v); // v[0] must be 0
        begin
            inst = 32'b0;
            inst[31]    = v[20];
            inst[30:21] = v[10:1];
            inst[20]    = v[11];
            inst[19:12] = v[19:12];
        end
    endtask

    task automatic check(input [8*8-1:0] name, input [2:0] src, input [31:0] expected);
        begin
            IMMsrc = src;
            #5;
            if (imm === expected) begin
                $display("T%0d PASS: %0s  imm=%h", t, name, imm);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL: %0s  got=%h exp=%h", t, name, imm, expected);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        // ===== I-type: sign-extend imm[11:0] =====
        pack_I(12'h001);  check("I +1   ", I_type, 32'h00000001);
        pack_I(12'h7FF);  check("I +2047", I_type, 32'h000007FF);
        pack_I(12'hFFF);  check("I -1   ", I_type, 32'hFFFFFFFF);
        pack_I(12'h800);  check("I -2048", I_type, 32'hFFFFF800);

        // ===== S-type: sign-extend imm[11:0] (scattered fields) =====
        pack_S(12'h001);  check("S +1   ", S_type, 32'h00000001);
        pack_S(12'h7FF);  check("S +2047", S_type, 32'h000007FF);
        pack_S(12'hFFF);  check("S -1   ", S_type, 32'hFFFFFFFF);
        pack_S(12'h800);  check("S -2048", S_type, 32'hFFFFF800);

        // ===== B-type: sign-extend imm[12:0], bit0=0 (even) =====
        pack_B(13'h0002); check("B +2   ", B_type, 32'h00000002);
        pack_B(13'h0FFE); check("B +4094", B_type, 32'h00000FFE);
        pack_B(13'h1FFE); check("B -2   ", B_type, 32'hFFFFFFFE);
        pack_B(13'h1000); check("B -4096", B_type, 32'hFFFFF000);

        // ===== U-type: imm[31:12] in high bits, low 12 = 0, NOT sign-extended =====
        pack_U(20'h00001); check("U small", U_type, 32'h00001000);
        pack_U(20'hFFFFF); check("U all-1", U_type, 32'hFFFFF000);
        pack_U(20'h7FFFF); check("U +max ", U_type, 32'h7FFFF000);

        // ===== J-type: sign-extend imm[20:0], bit0=0 (even) =====
        pack_J(21'h000002); check("J +2    ", J_type, 32'h00000002);
        pack_J(21'h0FFFFE); check("J +big  ", J_type, 32'h000FFFFE);
        pack_J(21'h1FFFFE); check("J -2    ", J_type, 32'hFFFFFFFE);
        pack_J(21'h100000); check("J -1M   ", J_type, 32'hFFF00000);

        // ===== default: unlisted IMMsrc -> 0 =====
        inst = 32'hFFFFFFFF;
        check("default", 3'b111, 32'h00000000);

        $display("=== IMMGEN RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule