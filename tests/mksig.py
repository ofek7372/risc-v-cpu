#!/usr/bin/env python3
"""
Parse a Spike --log-commits trace and emit two $readmemh signature files:
  <name>_reg.sig  - 32 lines, one per register x0..x31
  <name>_mem.sig  - 128 lines, one per data-memory byte
 
Usage:
    python3 mksig.py <spike.log> <name>
 
Untouched registers are emitted as 00000000 (the RTL regfile is zeroed by an
initial block, so untouched really means zero on the DUT side).
Untouched memory bytes are emitted as xx (the RTL data memory has no initial
block, so untouched is X on the DUT side and X !== X is false -> skipped).
That asymmetry is deliberate, not an oversight.
"""
 
import re
import sys
 
# --- configuration -----------------------------------------------------
# Hardcoded to match link.ld and the current test program. If the program
# grows past HALT_ADDR, or the linker script moves, update these.
TEXT_START = 0x2000   # inclusive - first instruction of _start
DATA_BASE  = 0x3000   # Spike address corresponding to RTL data_mem[0]
DATA_SIZE  = 4096      # bytes in the RTL data memory
 
# --- line patterns -----------------------------------------------------
# Commit lines look like:
#   core   0: 3 0x00002000 (0x00a00293) x5  0x0000000a
#   core   0: 3 0x00002080 (0x00822023) mem 0x00003000 0x00000001
# The "3" is the privilege level (machine mode), which also happens to
# distinguish commit lines from the fetch/disasm line above them.
COMMIT = re.compile(
    r"^core\s+\d+:\s+\d+\s+0x([0-9a-fA-F]+)\s+\(0x[0-9a-fA-F]+\)\s*(.*)$"
)
REG_WRITE = re.compile(r"^x(\d+)\s+0x([0-9a-fA-F]+)")
MEM_WRITE = re.compile(r"mem\s+0x([0-9a-fA-F]+)\s+0x([0-9a-fA-F]+)")
 
 
def main():
    if len(sys.argv) != 4:
        sys.exit("usage: mksig.py <spike.log> <name> <HALT_ADDR>")
 #arguments
    logpath, name, HALT_ADDR = sys.argv[1], sys.argv[2],sys.argv[3]
    HALT_ADDR= int(HALT_ADDR,16)
    regs = {}    # regnum -> 32-bit int, last write wins
    mem = {}     # byte address (Spike space) -> byte value, last write wins
    warnings = []
 
#Open the  file and read line by line 
    with open(logpath) as f:
        for line in f:
            m = COMMIT.match(line) 
            if not m:
                continue  # fetch lines, >>>> symbol markers, warnings
 	#if the line  matches  COMMIT pattern 
            pc = int(m.group(1), 16)
	    
            if not (TEXT_START <= pc < HALT_ADDR):
                continue  # Spike's boot ROM, or the halt loop
 
            rest = m.group(2).strip()
            if not rest:
                continue  # instruction with no architectural write (e.g. x0 dest)
 
            rw = REG_WRITE.match(rest)
            if rw:
                regs[int(rw.group(1))] = int(rw.group(2), 16)
 
            mw = MEM_WRITE.search(rest)
            if mw:
                # A load also emits "mem <addr>" but with no value field, so
                # MEM_WRITE (which requires two fields) only matches stores.
                addr = int(mw.group(1), 16)
                val_str = mw.group(2)          # raw hex string, e.g. "0033"
                val = int(val_str, 16)
                # Spike encodes store width in the value's digit count:
                # 8 digits -> sw (4 bytes), 4 -> sh (2 bytes), 2 -> sb (1 byte).
                nbytes = len(val_str) // 2
                for i in range(nbytes):
                    byte_addr = addr + i
                    if DATA_BASE <= byte_addr < DATA_BASE + DATA_SIZE:
                        mem[byte_addr] = (val >> (8 * i)) & 0xFF
                    else:
                        warnings.append(
                            f"store to 0x{byte_addr:08x} is outside the "
                            f"signature window "
                            f"[0x{DATA_BASE:x}, 0x{DATA_BASE + DATA_SIZE:x}) "
                            f"- DROPPED"
                        )

 
    # --- emit register signature ---------------------------------------
    regfile = f"{name}_reg.sig"
    with open(regfile, "w") as f:
        for r in range(32):
            # x0 is hardwired zero and never appears as a destination in the
            # log, so it falls through to the default like any untouched reg.
            f.write(f"{regs.get(r, 0):08x}\n")
 
    # --- emit memory signature (word per line, little-endian) ----------
    # Each line is one 32-bit word = 4 bytes. Within a word, each byte is
    # its hex value if written, or "xx" if untouched (per-byte granularity,
    # matching how the RTL data memory tracks written bytes). Byte 0 is the
    # LSB (rightmost), so bytes [b0,b1,b2,b3] -> "b3b2b1b0".
    memfile = f"{name}_mem.sig"
    with open(memfile, "w") as f:
        for w in range(DATA_SIZE // 4):          # 1024 words
            word_base = DATA_BASE + w * 4
            byte_strs = []
            for i in range(4):                    # bytes 3,2,1,0 -> MSB..LSB
                b = mem.get(word_base + (3 - i))
                byte_strs.append("xx" if b is None else f"{b:02x}")
            f.write("".join(byte_strs) + "\n")
 
    # --- report ---------------------------------------------------------
    for w in warnings:
        print(f"WARNING: {w}", file=sys.stderr)
 
    print(f"wrote {regfile} (32 registers, {len(regs)} written)")
    print(f"wrote {memfile} ({DATA_SIZE} bytes, {len(mem)} written)")
    if warnings:
        print(f"{len(warnings)} store byte(s) fell outside the window",
              file=sys.stderr)
        sys.exit(1)
 
 
if __name__ == "__main__":
    main()
 
