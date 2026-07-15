.section .text.start
.global _start

_start:
    la sp, _stack_top
    call main

hang:
    j hang

.section .bss
.space 4

.section .text
_stack_top = 0x00008000
