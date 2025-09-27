/* src/linker.ld */
ENTRY(_start)

SECTIONS
{
    . = 1M; /* Load address */

    .text : {
        *(.multiboot)
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}
