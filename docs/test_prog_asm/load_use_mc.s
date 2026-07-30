.section .text
.global _start
_start:
addi x10,x0,3
slli x10,x10,12

addi x11,x0,17
addi x12,x0,34
addi x13,x0,51
sw x11,0(x10)
sw x12,4(x10)
sw x13,8(x10)

lw x1,0(x10)
add x2,x1,x1

lw x3,4(x10)
sub x4,x3,x11
lw x5,8(x10)
add x6,x5,x4

lw x7,0(x10)
add x8,x7,x12
add x9,x8,x7

lw x14,4(x10)
and x15,x14,x13

sw x8,0(x10)
halt: j halt
