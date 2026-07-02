[bits 16]

; Setting up flat memory model
gdt_start:

gdt_null:
    dd 0x00000000
    dd 0x00000000

gdt_code:
    dw 0xffff      ; Limit
    dw 0x0000      ; Base 0-15
    db 0x00        ; Base 16-23
    db 10011010b   ; Access byte

    ; Flags and limit. Sets up protected mode descriptor
    ; as enabled and keeps long mode turned off.
    db 11001111b

    db 0x00        ; Base 24-31

gdt_data:
    dw 0xffff      ; Limit
    dw 0x0000      ; Base 0-15
    db 0x00        ; Base 16-23

    ; Access byte. Turns data segment read-only
    db 10010010b
    
    db 11001111b   ; Flags and limit
    db 0x00        ; Base 24-31

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Constants
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start