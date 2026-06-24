bits 16
org 0x7c00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Configuring stack
    mov ss, ax
    mov sp, 0x7c00

    mov si, msg
    call print_string

    ; Halt
    jmp $

msg db "Hello world!", 0

%include "./boot/print.asm"
%include "./boot/disk_read.asm"

times 510 - ($ - $$) db 0
dw 0xaa55