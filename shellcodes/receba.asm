[bits 16]

; Defines preamble and code size for communication
dw 0xAABB
dw end - start

start:
    ; Video memory address (center)
    mov ax, 0xb800
    mov es, ax
    mov di, 0x07c8

    ; Copies msg
    mov ax, 0x0a72      ; 'r'
    stosw
    mov ax, 0x0a65      ; 'e'
    stosw
    mov ax, 0x0a63      ; 'c'
    stosw
    mov ax, 0x0a65      ; 'e'
    stosw
    mov ax, 0x0a62      ; 'b'
    stosw
    mov ax, 0x0a61      ; 'a'
    stosw
    mov ax, 0x0a21      ; '!'
    stosw
end: