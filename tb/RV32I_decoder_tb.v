
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_decoder_tb
// Self-checking testbench for the one-level main decoder.
//
// Golden reference = the control table (Table 1) from the design document.
// Encodings (opcode/funct7[5]/funct3) verified against the ratified RISC-V spec
// (RV32/64G Instruction Set Listings, v20260120).
//
// The decoder is combinational and driven by (opcode, funct3, funct7).
// This tb builds full 32-bit instruction words so the funct7[5] bit lands at
// inst[30]; adjust the DUT port mapping below to match your actual decoder.
//
// IMMsrc for R-type is a don't-care in the spec table -> not checked for R-type.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_decoder_tb;

    localparam N = 40;

    // ---- DUT stimulus ----
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg        funct7_5;   // = inst[30]; wire to whatever your decoder consumes

    // ---- DUT outputs ----
    wire [3:0] ALUctrl;
    wire [2:0] ALUsrc;
    wire       REGwr, MEMwr, MEMrd, MEMtoREG;
    wire [2:0] IMMsrc;
    wire [1:0] JOP;
    wire       Bop;

    integer pass, fail, t;

    // ------------------------------------------------------------------
    // DUT INSTANTIATION
    // NOTE: match this to your actual decoder's port list & names.
    // Your decoder took (opcode, funct3, funct7) - if it takes full funct7,
    // wire {funct7_5, 6'b0}->funct7 won't be right for SUB/SRA detection,
    // so instead pass a full funct7 with bit5 = funct7_5.
    // ------------------------------------------------------------------
    //reg [6:0] funct7;
    //always @(*) funct7 = {1'b0, funct7_5, 5'b0}; // bit[5]=funct7_5, rest 0

    RV32I_decoder DUT (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUctrl(ALUctrl),
        .ALUsrc(ALUsrc),
        .REGwr(REGwr),
        .MEMwr(MEMwr),
        .MEMrd(MEMrd),
        .MEMtoREG(MEMtoREG),
        .IMMsrc(IMMsrc),
        .jop(JOP),
        .bop(Bop)
    );

    // ------------------------------------------------------------------
    // Checker.
    // check_imm = 1 -> compare IMMsrc; 0 -> skip (R-type don't-care).
    // ------------------------------------------------------------------
    task automatic check(
        input [8*8-1:0] name,
        input [6:0] in_opcode,
        input [2:0] in_funct3,
        input       in_funct7_5,
        input [3:0] e_ALUctrl,
        input [2:0] e_ALUsrc,
        input       e_REGwr,
        input       e_MEMwr,
        input       e_MEMrd,
        input       e_MEMtoREG,
        input [2:0] e_IMMsrc,
        input [1:0] e_JOP,
        input       e_Bop,
        input       check_imm
    );
        reg ok;
        begin
            opcode = in_opcode; funct3 = in_funct3; funct7_5 = in_funct7_5;
            #5;
            ok = (ALUctrl===e_ALUctrl) && (ALUsrc===e_ALUsrc) &&
                 (REGwr===e_REGwr) && (MEMwr===e_MEMwr) && (MEMrd===e_MEMrd) &&
                 (MEMtoREG===e_MEMtoREG) && (JOP===e_JOP) && (Bop===e_Bop) &&
                 ( check_imm ? (IMMsrc===e_IMMsrc) : 1'b1 );

            if (ok) begin
                $display("T%0d PASS: %0s", t, name);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL: %0s", t, name);
                $display("   got: ALUctrl=%b ALUsrc=%b REGwr=%b MEMwr=%b MEMrd=%b MEMtoREG=%b IMMsrc=%b JOP=%b Bop=%b",
                          ALUctrl, ALUsrc, REGwr, MEMwr, MEMrd, MEMtoREG, IMMsrc, JOP, Bop);
                $display("   exp: ALUctrl=%b ALUsrc=%b REGwr=%b MEMwr=%b MEMrd=%b MEMtoREG=%b IMMsrc=%b JOP=%b Bop=%b (imm_chk=%b)",
                          e_ALUctrl, e_ALUsrc, e_REGwr, e_MEMwr, e_MEMrd, e_MEMtoREG, e_IMMsrc, e_JOP, e_Bop, check_imm);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        // ============ R-type (opcode 0110011, IMMsrc = X -> not checked) ============
        //         name        opcode      f3    f7[5]  ALUctrl ALUsrc REG MEMwr MEMrd MtoR IMMsrc JOP  Bop chk_imm
        check("ADD ", 7'b0110011, 3'b000, 1'b0, 4'b0000, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("SUB ", 7'b0110011, 3'b000, 1'b1, 4'b0001, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("AND ", 7'b0110011, 3'b111, 1'b0, 4'b0010, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("OR  ", 7'b0110011, 3'b110, 1'b0, 4'b0011, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("XOR ", 7'b0110011, 3'b100, 1'b0, 4'b0100, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("SLT ", 7'b0110011, 3'b010, 1'b0, 4'b0101, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("SLTU", 7'b0110011, 3'b011, 1'b0, 4'b1000, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("SLL ", 7'b0110011, 3'b001, 1'b0, 4'b0110, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("SRL ", 7'b0110011, 3'b101, 1'b0, 4'b0111, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);
        check("SRA ", 7'b0110011, 3'b101, 1'b1, 4'b1001, 3'b000, 1,0,0,0, 3'bxxx, 2'b00, 0, 0);

        // ============ I-type ALU (opcode 0010011, IMMsrc=000) ============
        check("ADDI ", 7'b0010011, 3'b000, 1'b0, 4'b0000, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("ANDI ", 7'b0010011, 3'b111, 1'b0, 4'b0010, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("ORI  ", 7'b0010011, 3'b110, 1'b0, 4'b0011, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("XORI ", 7'b0010011, 3'b100, 1'b0, 4'b0100, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("SLTI ", 7'b0010011, 3'b010, 1'b0, 4'b0101, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("SLLI ", 7'b0010011, 3'b001, 1'b0, 4'b0110, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("SRLI ", 7'b0010011, 3'b101, 1'b0, 4'b0111, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("SLTIU", 7'b0010011, 3'b011, 1'b0, 4'b1000, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);
        check("SRAI ", 7'b0010011, 3'b101, 1'b1, 4'b1001, 3'b001, 1,0,0,0, 3'b000, 2'b00, 0, 1);

        // ============ Loads (opcode 0000011, ALUctrl 0000, IMMsrc=000, MEMrd=1, MEMtoREG=1) ============
        check("LW ", 7'b0000011, 3'b010, 1'b0, 4'b0000, 3'b001, 1,0,1,1, 3'b000, 2'b00, 0, 1);
        check("LH ", 7'b0000011, 3'b001, 1'b0, 4'b0000, 3'b001, 1,0,1,1, 3'b000, 2'b00, 0, 1);
        check("LB ", 7'b0000011, 3'b000, 1'b0, 4'b0000, 3'b001, 1,0,1,1, 3'b000, 2'b00, 0, 1);
        check("LHU", 7'b0000011, 3'b101, 1'b0, 4'b0000, 3'b001, 1,0,1,1, 3'b000, 2'b00, 0, 1);
        check("LBU", 7'b0000011, 3'b100, 1'b0, 4'b0000, 3'b001, 1,0,1,1, 3'b000, 2'b00, 0, 1);

        // ============ Stores (opcode 0100011, ALUctrl 0000, IMMsrc=011, MEMwr=1, REGwr=0) ============
        check("SW ", 7'b0100011, 3'b010, 1'b0, 4'b0000, 3'b001, 0,1,0,0, 3'b011, 2'b00, 0, 1);
        check("SH ", 7'b0100011, 3'b001, 1'b0, 4'b0000, 3'b001, 0,1,0,0, 3'b011, 2'b00, 0, 1);
        check("SB ", 7'b0100011, 3'b000, 1'b0, 4'b0000, 3'b001, 0,1,0,0, 3'b011, 2'b00, 0, 1);

        // ============ Branches (opcode 1100011, IMMsrc=001, Bop=1, REGwr=0) ============
        check("BEQ ", 7'b1100011, 3'b000, 1'b0, 4'b0001, 3'b000, 0,0,0,0, 3'b001, 2'b00, 1, 1);
        check("BNE ", 7'b1100011, 3'b001, 1'b0, 4'b0001, 3'b000, 0,0,0,0, 3'b001, 2'b00, 1, 1);
        check("BGE ", 7'b1100011, 3'b101, 1'b0, 4'b0101, 3'b000, 0,0,0,0, 3'b001, 2'b00, 1, 1);
        check("BLT ", 7'b1100011, 3'b100, 1'b0, 4'b0101, 3'b000, 0,0,0,0, 3'b001, 2'b00, 1, 1);
        check("BLTU", 7'b1100011, 3'b110, 1'b0, 4'b1000, 3'b000, 0,0,0,0, 3'b001, 2'b00, 1, 1);
        check("BGEU", 7'b1100011, 3'b111, 1'b0, 4'b1000, 3'b000, 0,0,0,0, 3'b001, 2'b00, 1, 1);

        // ============ Upper-immediate ============
        // LUI  (0110111, ALUsrc=010, IMMsrc=010)
        check("LUI  ", 7'b0110111, 3'b000, 1'b0, 4'b0000, 3'b010, 1,0,0,0, 3'b010, 2'b00, 0, 1);
        // AUIPC(0010111, ALUsrc=011, IMMsrc=010)
        check("AUIPC", 7'b0010111, 3'b000, 1'b0, 4'b0000, 3'b011, 1,0,0,0, 3'b010, 2'b00, 0, 1);

        // ============ Jumps ============
        // JAL  (1101111, ALUsrc=100, IMMsrc=100, JOP=01)
        check("JAL ", 7'b1101111, 3'b000, 1'b0, 4'b0000, 3'b100, 1,0,0,0, 3'b100, 2'b01, 0, 1);
        // JALR (1100111, funct3=000, ALUsrc=100, IMMsrc=000, JOP=10)
        check("JALR", 7'b1100111, 3'b000, 1'b0, 4'b0000, 3'b100, 1,0,0,0, 3'b000, 2'b10, 0, 1);

        // ============ Illegal / default (opcode not decoded -> all control zero) ============
        // Expect the safe bubble: everything 0. IMMsrc checked = 000 default.
        check("ILL1", 7'b1111111, 3'b000, 1'b0, 4'b0000, 3'b000, 0,0,0,0, 3'b000, 2'b00, 0, 1);
        check("ILL2", 7'b0000000, 3'b111, 1'b1, 4'b0000, 3'b000, 0,0,0,0, 3'b000, 2'b00, 0, 1);

        $display("=== DECODER RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule