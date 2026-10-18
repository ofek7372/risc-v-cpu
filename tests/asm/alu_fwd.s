.section .text
.global _start
_start:
    addi x5,x0,10
    xori x6,x5,2047
    ori  x7,x0,2047
    ori  x8,x0,1
    add  x9,x5,x8
    xor  x0,x5,x6
    and  x10,x0,x5
    sub  x0,x7,x8
    and  x11,x7,x0
    addi x1,x0,-1
    addi x3,x5,-6
    add  x2,x1,x0
    sll  x12,x8,x3
    addi x0,x0,20
    addi x20,x0,30
    sub  x21,x20,x0
    ori  x0,x5,1
    and  x5,x5,x5
    add  x22,x0,x6
    addi x30,x0,30
    addi x30,x0,31
    addi x31,x30,5
    add  x20,x5,x5
    sub  x20,x5,x8
    and  x25,x5,x20
    addi x20,x20,1
    sub  x6,x6,x5
    add  x0,x0,x0
    add  x13,x20,x0
    add  x15,x0,x6
    addi x4,x0,3
    sll  x4,x4,12
    sw   x8,0(x4)
halt: j halt

