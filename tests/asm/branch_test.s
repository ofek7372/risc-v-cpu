.section .text
.global _start
_start:
addi x10,x0,3
slli x10,x10,12
addi x1,x0,1
addi x2,x0,5
addi x3,x0,5
addi x4,x0,9

# TEST 1: taken branch flushes shadow
beq x2,x3,t1_target
sw x1,0(x10)          # CANARY0 : untouched if flush works
t1_target:
sw x1,4(x10)          # CANARY1 : landing marker

# TEST 2: not-taken does NOT flush
beq x2,x4,t2_skip
sw x1,8(x10)          # CANARY2 : must be written
t2_skip:
sw x1,12(x10)         # CANARY3 : landing marker

# TEST 3: ALU-into-branch, distance-1 stall
addi x6,x0,9
add x6,x2,x3          # x6=10, stall needed
beq x6,x4,t3_stale    # 10==9? no -> fall through (correct)
sw x1,16(x10)         # CANARY4 : written if correct
beq x0,x0,t3_done
t3_stale:
sw x1,20(x10)         # CANARY5 : written only if wrongly taken
t3_done:

# TEST 4: load-into-branch, distance-2 stall
addi x7,x0,9
sw x7,24(x10)
lw x8,24(x10)         # x8=9
add x9,x0,x0          # filler
beq x8,x4,t4_target   # 9==9 -> taken (correct)
sw x1,28(x10)         # CANARY6 : written if wrongly fell through
t4_target:
sw x1,32(x10)         # CANARY7 : landing marker

halt: j halt
