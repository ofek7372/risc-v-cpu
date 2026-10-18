# RV32I 5-Stage Pipelined CPU

A 5-stage in-order RISC-V (RV32I) processor written in Verilog, implemented on a Digilent Arty A7-35T (`xc7a35tcsg324-1`), and verified instruction-by-instruction against the Spike ISA simulator.

| | |
|---|---|
| ISA | RV32I base integer: 37 of 40 instructions (FENCE, ECALL, EBREAK decode as no-ops; see [Scope](#scope)) |
| Pipeline | IF → ID → EX → MEM → WB, in-order, single-issue |
| Hazards | Full forwarding (MEM→EX, WB→EX, WB→ID), 1-cycle load-use stall, static not-taken branch prediction |
| Verification | 9 self-checking programs compared against Spike: all 32 registers and 1024 data-memory words per program; 37/37 instructions exercised |
| FPGA | 50 MHz, timing met (WNS +0.232 ns, WHS +0.122 ns); 1,804 LUTs (8.7%), 374 FFs (0.9%), 0.5 BRAM, 0 DSP |

---

## Architecture

<!-- TODO: replace with an up-to-date block diagram. docs/RISC_V- PIPELINE_block_diagram.png shows the earlier
     design (branch resolution in ID, no load/store units) and no longer matches the RTL. -->

| Stage | What happens | Key modules |
|---|---|---|
| **IF** | PC drives a synchronous-read instruction ROM (block RAM). A PC delay register keeps PC and instruction aligned across the 1-cycle read latency. | `PC`, `SC_instruction_mem`, `RV32I_PC_delay`, `RV32I_IF_ID` |
| **ID** | Single-level decoder produces all control signals. Immediate generator handles I/S/B/U/J formats. Register file is read with a WB→ID bypass so a value written this cycle is read correctly. | `RV32I_decoder`, `RV32I_IMMgen`, `SC_REG_FILE`, `REG_forwarding_unit`, `RV32I_bubble` |
| **EX** | Forwarding muxes select operands from EX/MEM or MEM/WB. ALU source mux selects the operand pair: rs1/rs2, rs1/imm, 0/imm (LUI), PC/imm (AUIPC) or PC/4 (JAL/JALR link address). Branch condition and jump target are resolved here. | `RV32I_EX_FWD`, `RV32I_ALUsrc`, `ALU_v1`, `RV32I_branch`, `RV32I_Target_adder` |
| **MEM** | Store unit positions byte/halfword data on the correct lanes and generates byte enables. Load unit extracts and sign/zero-extends. | `RV32I_store_unite`, `RV32I_addr_decoder`, `RV32I_data_mem`, `RV32I_load_unit` |
| **WB** | Result written back to the register file. | `RV32I_MEM_WB` |

**Memory map.** Harvard: separate instruction and data memories, 4 KB each.

| Region | Base | Size |
|---|---|---|
| Instruction ROM | `0x2000` | 1024 words |
| Data RAM | `0x3000` | 1024 words, byte-enable writes |

### Hazard handling

| Hazard | Handling | Cost |
|---|---|---|
| ALU result needed by the next instruction | Forward from EX/MEM | 0 cycles |
| Result needed two instructions later | Forward from MEM/WB | 0 cycles |
| Register written and read in the same cycle | WB→ID bypass in the register file read path | 0 cycles |
| Load result needed by the next instruction | Stall 1 cycle (bubble into ID/EX), then forward | 1 cycle |
| Taken branch / any jump | Predict not-taken; on misprediction flush IF/ID and ID/EX | 2 cycles |

**Why branches resolve in EX.** The first pipeline resolved BEQ/BNE in ID, with its own comparator and branch forwarding. Extending to the full ISA added four more branch conditions and two jumps. Keeping them in ID would have meant more target adders and comparison logic there, while the ALU, the forwarding muxes and a target adder in EX already sat unused for these instructions. So all control flow moved to EX.

The cost is a 2-cycle misprediction penalty instead of 1, and the branch decision and PC mux now sit at the end of the EX path, which is where the current critical path ends (see [FPGA results](#fpga-results)).

---

## Verification

Each program is assembled, run on [Spike](https://github.com/riscv-software-src/riscv-isa-sim), and the final architectural state is extracted as a reference *signature*. The CPU runs the same binary in simulation, and the testbench compares every register and every data-memory word against the signature.

```
program.s ──► riscv32 as/ld ──► .elf ──┬──► objcopy ──► program_inst.hex ──► RTL simulation ──┐
                                        └──► Spike ──► commit log ──► mksig.py ──► .sig files ───┴──► compare
```

Flow: [`tests/build.sh`](tests/build.sh), [`tests/mksig.py`](tests/mksig.py), [`tests/link.ld`](tests/link.ld)

| Program | Targets | Result |
|---|---|---|
| [`alu_fwd`](tests/asm/alu_fwd.s) | EX/MEM and MEM/WB forwarding, writes to `x0` | pass |
| [`load_use`](tests/asm/load_use.s), [`load_use_mc`](tests/asm/load_use_mc.s) | Load-use stalls, chained dependencies | pass |
| [`branch_test`](tests/asm/branch_test.s) | Taken/not-taken flush, ALU→branch and load→branch dependencies | pass |
| [`testbranch2`](tests/asm/testbranch2.s) | BLT, BGE, BLTU, BGEU, JAL | pass |
| [`testprog1`](tests/asm/testprog1.s) | LB, LH, LBU, LHU, SB, SH (all byte/halfword lanes) | pass |
| [`testprog2`](tests/asm/testprog2.s) | LUI, AUIPC, JAL, JALR | pass |
| [`testprog3`](tests/asm/testprog3.s) | SLTU, SLTIU, SRA, SRAI, SRLI | pass |
| [`isa_cover`](tests/asm/isa_cover.s) | Remaining R/I-type ops, BNE taken and not taken | pass |

All 9 pass in Vivado XSim and in Icarus Verilog. Every module also has a unit testbench in [`tb/`](tb/).

**Spike vs. this CPU's memory map.** Spike is run with one flat region at `0x2000`; the CPU uses separate instruction and data memories. The data-memory address decoder subtracts the `0x3000` base, so a store to `0x3000` in Spike lands at word 0 of the CPU's data RAM and the two signatures line up.

---

## FPGA results

Arty A7-35T, Vivado post-route, 50 MHz from the 100 MHz board clock via a clocking wizard.

| Resource | Used | Available | Utilisation |
|---|---|---|---|
| LUTs | 1,804 | 20,800 | 8.7% |
| Flip-flops | 374 | 41,600 | 0.9% |
| Block RAM | 0.5 | 50 | 1.0% |
| DSP | 0 | 90 | 0% |

| Timing | |
|---|---|
| WNS / TNS | +0.232 ns / 0 |
| WHS / THS | +0.122 ns / 0 |
| Estimated Fmax | ≈ 50.6 MHz |

**Critical path (19.75 ns, 30 logic levels, 68% routing):** `EX/MEM.ALUresult` → data memory (distributed LUT-RAM, async read) → load unit → MEMtoREG mux → **forwarded to EX** → ALU → branch decision → PC mux → `PC`.

The path exists because the EX forwarding unit forwards the post-load-mux value (`MEM_WBdata`) from the MEM stage. Since every load-use dependency is already stalled by one cycle, load data never needs to be forwarded from MEM, but synthesis cannot know that and times the path anyway. Forwarding `MEM_ALUresult` instead should remove the data memory from the path. Not yet implemented; see [Next steps](#next-steps).

**On the board.** <!-- TODO after uni tomorrow: confirm the board runs a program and the LEDs show the expected value. -->
`arty_top` wraps the CPU: `btn[0]` resets, `sw[0]` enables, and `led[3:0]` show the low 4 bits of the last value written to `x10`.

---

## Scope

- **Implemented:** all RV32I computational, load/store, branch and jump instructions (37).
- **Decoded as no-ops:** FENCE (single in-order core, no memory reordering to order), ECALL, EBREAK. There is no privileged mode, no CSRs and no trap handling. The project targets the unprivileged base ISA.
- **Not handled:** misaligned loads/stores. Only naturally aligned accesses are tested.
- **Not run:** the official `riscv-arch-test` compliance suite.

---

## Repository layout

```
rtl/            RTL. RV32I_top.v is the CPU top; arty_top.v is the board wrapper
tb/             Unit testbenches and the full-CPU testbench (piplined_param_tb.v)
tests/
  asm/          Test programs (RISC-V assembly)
  hex/          Assembled instruction memory images
  sig/          Spike reference signatures (registers + data memory)
  build.sh      .s → hex + signatures
constraints/    Arty A7-35T pin constraints
ip/             Clocking wizard configuration (100 → 50 MHz)
docs/           Design diagrams
```

`SC_top_module.v` (single-cycle CPU) and `pipeline_top_module.v` with the `PR_*`, `Branch_*`, `ALU_forwarding_unit` and `bubble_insertion_unit` files (first pipeline, 19-instruction subset) are earlier stages of the project, kept for history. `RV32I_top` reuses only `PC`, `SC_instruction_mem`, `SC_REG_FILE`, `REG_forwarding_unit` and `ALU_v1` from them.

## Running the tests

```bash
# Generate a test (needs riscv32-unknown-elf toolchain + Spike)
cd tests && ./build.sh asm/<program>.s   # steps 7-9 copy into my local Vivado folders; edit or delete them

# Simulate one program (Icarus example), from the repo root
iverilog -g2012 -s piplined_param_tb -P 'piplined_param_tb.NAME="isa_cover"' \
         -o sim.out tb/piplined_param_tb.v rtl/*.v
vvp sim.out          # prints "passed" or "<n> fails"
```

`NAME` is any program in `tests/asm/`. In Vivado, set the testbench generic `ROOT` to the absolute repo path with a trailing `/` (XSim runs from inside `project_2.sim/`).

## Next steps

1. Forward `MEM_ALUresult` instead of `MEM_WBdata` from the MEM stage, re-verify, and re-measure Fmax.
2. Run the official `riscv-arch-test` suite.
3. Trap handling (ECALL/EBREAK, misaligned access) with a minimal machine-mode CSR set.
