`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ALU_v1_tb
// Self-checking testbench for the 10-operation ALU (WIDTH=32).
//
// Ops (alu_ctrl): 0000 ADD, 0001 SUB, 0010 AND, 0011 OR, 0100 XOR,
//                 0101 SLT(signed), 0110 SLL, 0111 SRL, 1000 SLTU, 1001 SRA
//
// Expected values are computed in the tb using Verilog operators, but with the
// SAME semantics the ALU must implement (5-bit shift amount, signed vs unsigned
// compares, signed arithmetic shift). Directed edge cases + random vectors.
//////////////////////////////////////////////////////////////////////////////////
module ALU_v1_tb;

    localparam WIDTH = 32;

    localparam ADD=4'b0000, SUB=4'b0001, AND_=4'b0010, OR_=4'b0011, XOR_=4'b0100,
               SLT=4'b0101, SLL=4'b0110, SRL=4'b0111, SLTU=4'b1000, SRA=4'b1001;

    reg  [WIDTH-1:0] a, b;
    reg  [3:0] alu_ctrl;
    wire [WIDTH-1:0] Y;
    wire cout_borrow, zero, negative;

    integer pass, fail, t, i;

    ALU_v1 #(.WIDTH(WIDTH)) DUT (
        .a(a), .b(b), .alu_ctrl(alu_ctrl),
        .Y(Y), .cout_borrow(cout_borrow), .zero(zero), .negative(negative)
    );

    // ---- reference model: returns expected Y for given op/a/b ----
    function [WIDTH-1:0] expY(input [3:0] op, input [WIDTH-1:0] av, bv);
        reg [4:0] sh;
        begin
            sh = bv[4:0];                       // RV32I shifts use low 5 bits
            case (op)
                ADD:  expY = av + bv;
                SUB:  expY = av - bv;
                AND_: expY = av & bv;
                OR_:  expY = av | bv;
                XOR_: expY = av ^ bv;
                SLT:  expY = ($signed(av) < $signed(bv)) ? 1 : 0;
                SLL:  expY = av << sh;
                SRL:  expY = av >> sh;
                SLTU: expY = (av < bv) ? 1 : 0;   // unsigned compare
                SRA:  expY = $signed(av) >>> sh;
                default: expY = 0;
            endcase
        end
    endfunction

    task automatic check(input [8*8-1:0] name, input [3:0] op, input [WIDTH-1:0] av, bv);
        reg [WIDTH-1:0] e;
        begin
            a = av; b = bv; alu_ctrl = op;
            #5;
            e = expY(op, av, bv);
            if (Y === e) begin
                // also spot-check zero/negative flags against Y
                if (zero !== (~|Y)) begin
                    $error("T%0d FAIL(%0s): zero flag wrong (Y=%h zero=%b)", t, name, Y, zero);
                    fail = fail + 1;
                end else if (negative !== Y[WIDTH-1]) begin
                    $error("T%0d FAIL(%0s): negative flag wrong (Y=%h neg=%b)", t, name, Y, negative);
                    fail = fail + 1;
                end else begin
                    pass = pass + 1;
                end
            end else begin
                $error("T%0d FAIL(%0s): a=%h b=%h  Y=%h exp=%h", t, name, av, bv, Y, e);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        // ===== ADD: incl. carry-out cases =====
        check("ADD0",  ADD, 32'd5, 32'd7);
        check("ADDneg",ADD, 32'hFFFFFFFF, 32'd1);        // wraps, carry out
        check("ADDmax",ADD, 32'h7FFFFFFF, 32'd1);        // signed overflow region

        // ===== SUB: incl. borrow =====
        check("SUB0",  SUB, 32'd10, 32'd3);
        check("SUBneg",SUB, 32'd3, 32'd10);              // negative result / borrow
        check("SUBeq", SUB, 32'd42, 32'd42);             // zero result -> zero flag

        // ===== bitwise =====
        check("AND",   AND_, 32'hF0F0F0F0, 32'h0FF00FF0);
        check("OR",    OR_,  32'hF0F0F0F0, 32'h0F0F0F0F);
        check("XOR",   XOR_, 32'hAAAAAAAA, 32'hFFFFFFFF);

        // ===== SLT (signed) =====
        check("SLT_t", SLT, 32'hFFFFFFFF, 32'd1);        // -1 < 1 -> 1
        check("SLT_f", SLT, 32'd1, 32'hFFFFFFFF);        // 1 < -1 -> 0
        check("SLT_eq",SLT, 32'd5, 32'd5);               // 0

        // ===== SLTU (unsigned) : same bits, different result than SLT =====
        check("SLTU_f",SLTU, 32'hFFFFFFFF, 32'd1);       // 0xFFFFFFFF > 1 unsigned -> 0
        check("SLTU_t",SLTU, 32'd1, 32'hFFFFFFFF);       // 1 < big -> 1

        // ===== SLL / SRL : shift amount is low 5 bits only =====
        check("SLL1",  SLL, 32'h00000001, 32'd4);        // ->0x10
        check("SLL31", SLL, 32'h00000001, 32'd31);       // ->0x80000000
        check("SLLmask",SLL,32'h00000001, 32'd32);       // 32 & 31 = 0 -> unchanged
        check("SRL1",  SRL, 32'h80000000, 32'd4);        // logical -> 0x08000000
        check("SRLmask",SRL,32'h80000000, 32'd33);       // 33&31=1 -> 0x40000000

        // ===== SRA : arithmetic, MUST sign-extend for negative a =====
        check("SRA_neg",SRA, 32'h80000000, 32'd4);       // -> 0xF8000000 (sign fill)
        check("SRA_pos",SRA, 32'h40000000, 32'd4);       // -> 0x04000000 (zero fill)
        check("SRA_m1", SRA, 32'hFFFFFFFF, 32'd10);      // -1 >>> anything = -1
        check("SRAmask",SRA, 32'h80000000, 32'd36);      // 36&31=4 -> 0xF8000000

        // ===== random vectors across all ops =====
        for (i = 0; i < 200; i = i + 1) begin
            a = $random; b = $random;
            check("RND_ADD", ADD,  a, b);
            check("RND_SUB", SUB,  a, b);
            check("RND_AND", AND_, a, b);
            check("RND_OR",  OR_,  a, b);
            check("RND_XOR", XOR_, a, b);
            check("RND_SLT", SLT,  a, b);
            check("RND_SLTU",SLTU, a, b);
            check("RND_SLL", SLL,  a, b);
            check("RND_SRL", SRL,  a, b);
            check("RND_SRA", SRA,  a, b);
        end

        $display("=== ALU RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule