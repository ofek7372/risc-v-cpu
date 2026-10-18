.section .text
.global _start
_start:
addi x4,x0,3
slli x4,x4,12
addi x5,x0,2
sw x5, 0(x4)
lw x3,0(x4)
sub x1, x3, x4
sw x5, 4(x4)
sw x5, 12(x4)
sw x5, 20(x4)
halt: j halt

