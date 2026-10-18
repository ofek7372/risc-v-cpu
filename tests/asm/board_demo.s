.section .text
.global _start
_start:
    lui  x5, 0x3            # data base 0x3000
    addi x1, x0, 7
    addi x2, x0, 3
    add  x3, x1, x2         # 10, forwarded from both prior instructions
    sw   x3, 0(x5)
    lw   x4, 0(x5)
    addi x4, x4, 0          # load-use stall
    bne  x4, x3, fail       # not taken if store/load/forwarding all worked
    addi x10, x4, 0         # x10 = 10 = 0b1010
halt: j halt
fail:
    addi x10, x0, 5         # 0b0101 = something went wrong
    j halt
