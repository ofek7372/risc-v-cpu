.section .text
.global _start
_start:
    lui  x10, 0x3          # x10 = 0x3000, data base
    addi x1, x0, -5
    addi x2, x0, 3
    sll  x3, x2, x2        # 24, RAW on x2
    slt  x4, x1, x2        # -5 < 3 signed -> 1
    slt  x5, x2, x1        # 0
    xor  x6, x3, x1        # RAW on x3
    srl  x7, x1, x2        # logical shift of a negative -> 0x1FFFFFFF
    or   x8, x6, x2        # RAW on x6
    slti x9, x1, -4        # -5 < -4 -> 1
    slti x11, x2, -4       # 0
    ori  x12, x1, 0x0f0
    andi x13, x1, 0x7ff
    andi x14, x1, -16
    bne  x2, x2, bad       # not taken
    addi x15, x0, 1        # must execute
    bne  x1, x2, ok        # taken
    addi x16, x0, 99       # must be flushed
ok:
    sw x3, 0(x10)
    sw x4, 4(x10)
    sw x7, 8(x10)
    sw x8, 12(x10)
    sw x12, 16(x10)
    sw x14, 20(x10)
halt: j halt
bad:
    addi x17, x0, 77       # only reached if bne is wrong
    j halt
