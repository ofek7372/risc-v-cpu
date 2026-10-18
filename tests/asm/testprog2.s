.section .text
.global _start
_start:

addi x1,x0,3
slli x1,x1,12

lui x2,0x5555
sw x2,0(x1)
auipc x3,0x2020
sw x3,4(x1)

jal x4,jmp_1
ret_1:
sw x3,8(x1)
jal x0, skip
jmp_1:
 xori x3,x3,-1
jalr x0,0(x4)
skip: 
halt: j halt


