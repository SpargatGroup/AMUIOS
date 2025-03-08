ENTRY(_start)

SECTIONS
{
	. = 0xffffffff80000000;

	.bootstrap : { *(.bootstrap) }
	.phdr5 : { *(.phdr5) }
	.test : { *(.text) *(.text.*) }
	.rodata : { *(.rodata) *(.rodata.*) }
	.data : { *(.data) *(.data.*) }
	.bss : { *(.bss) *(.bss.*) }
}