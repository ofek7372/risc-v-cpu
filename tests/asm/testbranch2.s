.section .text
.global _start
_start:
#build store address
addi x1 ,x0, 3
slli x1,x1,12
# tests taken for BLT and BLTU

addi x2,x0,-1
addi x3,x0,1
addi x4,x0,4
addi x5,x0,4
#store x2 marks passed correctly, store x31 marks wrote uncorrectly
#test 1  BLT signed branch

#expected taken
blt x2,x3, t1_t
sw x31,0(x1)
jal x0, t1_nt
t1_t:
sw x2,4(x1)
t1_nt:
#expected not taken
blt x3,x2, t2_t
sw x2,8(x1)
jal x0,t2_nt
t2_t:
sw x31,12(x1)
t2_nt:
#expected taken
#test 3 BLTU
bltu x3,x2,t3_t
sw x31,16(x1)
jal x0,t3_nt
t3_t:
sw x2,20(x1)
t3_nt:
#expected not taken
bltu x2,x3,t4_t
sw x2,24(x1)
jal x0,t4_nt
t4_t:
sw x31,28(x1)
t4_nt:
#test 5 BGE
#expected taken
bge x3,x2,t5_t
sw x31,32(x1)
jal x0,t5_nt
t5_t:
sw x2,36(x1)
t5_nt:

#expected not taken
bge x2,x3,t6_t
sw x2,40(x1)
jal x0,t6_nt
t6_t:
sw x31,44(x1)
t6_nt:

#expected taken equality:
bge x4,x5,t7_t
sw x31,48(x1)
jal x0,t7_nt
t7_t:
sw x2,52(x1)
t7_nt:

#test bgeu
#exp taken
bgeu x2,x3,t8_t
sw x31,56(x1)
jal x0,t8_nt
t8_t:
sw x2,60(x1)
t8_nt:
#exp not taken
bgeu x3,x2,t9_t
sw x2,64(x1)
jal x0,t9_nt
t9_t:
sw x31,68(x1)
t9_nt:
#exp taken
bgeu x5,x4,t10_t
sw x31,72(x1)
jal x0,t10_nt
t10_t:
sw x2,76(x1)
t10_nt:

addi x6,x0,6
addi x7,x0,7
sw x7,80(x1)
lw x8,80(x1)
bge x8,x7,t11_t
sw x31,84(x1)
jal x0,t11_nt
t11_t:
sw x2,88(x1)
t11_nt:

halt:j halt
