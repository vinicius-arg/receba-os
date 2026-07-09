[bits 16]

switch_to_pm:
    cli

    ; Loading GDT
    mov si, lgdt_msg
    call print_string

    lgdt [gdt_descriptor]

    ; Enabling protected mode
    mov eax, cr0
    or eax, 0x1     ; Enables PE bit
    mov cr0, eax

    ; Flushes CPU pipeline
    jmp CODE_SEG:init_pm

[bits 32]

init_pm:
    ; Initializing segment registers
    ; Guarantees consistently memory accesses through CPU reqs
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Building 32-bit stack
    mov ebp, 0x90000
    mov esp, ebp

    call begin_pm

%include "gdt.asm"

lgdt_msg db "Loading Global Descriptor Table...", 13, 10, 0