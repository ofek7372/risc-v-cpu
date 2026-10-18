.section .text
.global _start
_start:
addi x1,x0,3
slli x1,x1,12

# ===== x0 forwarding guard =====
# add to x0 (legal, result discarded), immediately followed by a read of x0
addi x2,x0,99
add x0,x2,x2          # x0 should stay 0, forwarding must NOT deliver 198
add x3,x0,x0           # x3 must be 0 if the x0 guard held
sw x3,0(x1)            # expect 0 at [0]

# same test but on the EX_FWD path (distance-1, EX-stage forward attempt)
addi x4,x0,55
sub x0,x4,x0            # write-to-x0 attempt, discarded
add x5,x0,x4             # x5 = 0 + 55 = 55 if x0 stayed 0
sw x5,4(x1)             # expect 55 at [4]

# ===== SLTU =====
addi x6,x0,-1            # x6 = 0xFFFFFFFF
addi x7,x0,1
sltu x8,x7,x6             # 1 < 0xFFFFFFFF unsigned -> 1
sltu x9,x6,x7             # 0xFFFFFFFF < 1 unsigned -> 0
sw x8,8(x1)             # expect 1
sw x9,12(x1)            # expect 0

# ===== SLTIU =====
sltiu x10,x7,5           # 1 < 5 unsigned -> 1
sltiu x11,x6,5           # 0xFFFFFFFF < 5 unsigned -> 0
sw x10,16(x1)            # expect 1
sw x11,20(x1)            # expect 0

# ===== SRA (arithmetic, sign-extends) =====
addi x12,x0,-16          # x12 = 0xFFFFFFF0  (-16)
srai x13,x12,2            # -16 >>> 2 = -4  (arithmetic, sign fill)
sw x13,24(x1)            # expect 0xFFFFFFFC (-4)

addi x14,x0,16            # positive
srai x15,x14,2            # 16 >>> 2 = 4 (zero fill, positive stays positive)
sw x15,28(x1)            # expect 4

# register-register SRA
addi x16,x0,2
sra x17,x12,x16           # -16 >> 2 = -4 (same as srai case, via register shift amt)
sw x17,32(x1)             # expect 0xFFFFFFFC

# contrast with SRL (logical) on same negative value to prove they differ
srli x18,x12,2             # logical shift of 0xFFFFFFF0 >> 2 = 0x3FFFFFFC (zero fill)
sw x18,36(x1)              # expect 0x3FFFFFFC (must differ from SRA result)

halt: j halt
