[bits 16]

; TODO: Make this work
; This routine saves IVT to hidden addresses in range [0x0013]:0x0000, [0x0013]:0x03ff
save_ivt:
    pusha
    push ds
    push es

    ; Sets ds:si to 0x0000 (pointers IVT), source
    xor ax, ax
    mov ds, ax
    xor si, si

    ; Sets safe saving address as destiny
    mov ax, [0x0013]        ; Getting total RAM in BIOS Data Area (924 kB)
    shl ax, 6
    mov es, ax
    xor di, di              ; Setting es:di to [0x0013]:0x0000

    mov cx, 512

    ; Executes copy
    cld
    rep movsw

    pop es
    pop ds
    popa
    ret

; This routine loads IVT from pre-saved addresses in range [0x0013]:0x0000, [0x0013]:0x03ff
load_ivt:
    pusha
    push ds
    push es

    ; Sets loading address as source
    mov ax, [0x0013]        ; Getting total RAM in BIOS Data Area (924 kB)
    shl ax, 6
    mov ds, ax
    xor si, si

    ; Sets ds:si to 0x0000 as destiny (pointers IVT)
    xor ax, ax
    mov es, ax
    mov di, ax

    mov cx, 512

    ; Executes copy
    cld
    rep movsw

    pop es
    pop ds
    popa
    ret