#!/bin/bash
# Usage: ./build.sh <program.s> [instruction_count]
# Produces: <name>_inst.hex, <name>_reg.sig, <name>_mem.sig

SRC=$1
NAME=$(basename $SRC .s)
INSTR=${2:-5000}          # optional 2nd arg, defaults to 5000

# 1. assemble
riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o $NAME.o $SRC

# 2. link
riscv32-unknown-elf-ld -T link.ld -o $NAME.elf $NAME.o

# 3. instruction hex
riscv32-unknown-elf-objcopy -O binary -j .text $NAME.elf $NAME.bin
xxd -e -c4 $NAME.bin | awk '{print $2}' > ${NAME}_inst.hex

# 4. find halt address
HALT=$(riscv32-unknown-elf-nm $NAME.elf | grep halt | awk '{print $1}')

# 5. run spike
spike --isa=rv32i -m0x2000:0x2000 --instructions=$INSTR -l --log-commits $NAME.elf > $NAME.log 2>&1

# 6. signatures
python3 mksig.py $NAME.log $NAME $HALT

# --- 7. copy signature files to the signiture folder ---
SIG_DEST=/mnt/c/Users/ec24673/project_2/signiture
SIG_DEST_WIN="C:/Users/ec24673/project_2/signiture"
if [ ! -d "$SIG_DEST" ]; then
    echo "ERROR: signature destination $SIG_DEST does not exist"
    exit 1
fi
cp ${NAME}_reg.sig ${NAME}_mem.sig $SIG_DEST/
echo "copied signatures to $SIG_DEST"

#signiture paths
echo "${SIG_DEST_WIN}/${NAME}_reg.sig" > ${NAME}_reg_path.txt
cp ${NAME}_reg_path.txt $SIG_DEST/

echo "${SIG_DEST_WIN}/${NAME}_mem.sig" > ${NAME}_mem_path.txt
cp ${NAME}_mem_path.txt $SIG_DEST/


# --- 8. copy instruction hex to the tests_mem folder ---
INST_DEST_WSL=/mnt/c/Users/ec24673/project_2/tests_mem
INST_DEST_WIN="C:/Users/ec24673/project_2/tests_mem"   # readmemh format: forward slashes, drive letter
if [ ! -d "$INST_DEST_WSL" ]; then
    echo "ERROR: instruction destination $INST_DEST_WSL does not exist"
    exit 1
fi
cp ${NAME}_inst.hex $INST_DEST_WSL/
echo "copied instruction hex to $INST_DEST_WSL"

# --- 9. write a readmemh-format path helper file ---
echo "${INST_DEST_WIN}/${NAME}_inst.hex" > ${NAME}_path.txt
cp ${NAME}_path.txt $INST_DEST_WSL/

echo "wrote path helper: ${NAME}_path.txt"
echo "done: ${NAME}_inst.hex, ${NAME}_reg.sig, ${NAME}_mem.sig"
