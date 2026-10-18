.section .text
.global _start
_start:
addi x10,x0,3
slli x10,x10,12

addi x1,x0,0x111
addi x2,x0,0x222

addi x3,x0,0x0033
addi x4,x0,0x0044

addi x5,x0,0x0000005
addi x6,x0,0x0000006

sw x1,0(x10)
sw x2,4(x10)
sh x3,8(x10)
sh x4,12(x10)
sb x5,16(x10)
sb x6,20(x10)

lw x11,0(x10)
lb x12,20(x10)
lh x13,8(x10)
lhu x14,8(x10)
lh x15,12(x10)
lhu x16,12(x10)
lb x17,16(x10)
lbu x18,16(x10)
lb x19,4(x10)
lbu x20,4(x10)
halt: j halt

