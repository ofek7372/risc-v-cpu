ENTRY(_start)

MEMORY
{
  IMEM (rx)  : ORIGIN = 0x2000, LENGTH = 0x1000
  DMEM (rw)  : ORIGIN = 0x3000, LENGTH = 0x1000
}

SECTIONS
{
  .text : { *(.text*) } > IMEM
  .data : { *(.data*) } > DMEM
}

