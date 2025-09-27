; src/boot.asm

; Multiboot header
section .multiboot
align 4
    dd 0x1BADB002        ; Magic number
    dd 0x00              ; Flags
    dd - (0x1BADB002 + 0x00) ; Checksum

; Stack setup
section .bss
resb 8192                ; 8KB stack
stack_top:

; Entry point
section .text
global _start
extern kmain             ; Function in our Zig code

_start:
    ; Set up the stack
    mov esp, stack_top

    ; Call the Zig kernel main function
    call kmain

    ; Halt the CPU
    cli
.hang:
    hlt
    jmp .hang
