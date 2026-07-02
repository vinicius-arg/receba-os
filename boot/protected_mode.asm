[bits 16]

switch_to_pm:
    cli

    ; Loading GDT
    mov si, load_gdt
    call print_string
    lgdt [gdt_descriptor]

    ; Enabling protected mode
    mov si, en_pmode
    call print_string
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

%include "./boot/print16.asm"

load_gdt db "Loading Global Descriptor Table...", 0
en_pmode db "Switched to 32-bit Protected Mode.", 0
