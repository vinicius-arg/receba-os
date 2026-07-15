[bits 16]

exec_code:
    pusha
    push ds
    push es

    ; Sets segments
    mov ax, cs
    mov ds, ax
    mov es, ax
    
    mov di, (buffer - hooks_start)

    ; Getting size in binary reader
    call sread_byte
    mov cl, al
    call sread_byte
    mov ch, al
    
    cmp cx, 0               
    je .abort

    ; Prepares reading loop
    cld
    .read_loop:
        call sread_byte
        stosb                    ; Do mov [es:di], al and inc di

        loop .read_loop

    .end:
        mov byte [di], 0xc3    ; ret
        call buffer
        
        pop es
        pop ds
        popa
        ret
    
    .abort:
        pop es
        pop ds
        popa
        ret

sread_byte:
    push dx
    mov dx, 0x3fd   ; COM1 virtual port

    .waitb:
        in al, dx
        test al, 0x1                ; Data Ready bit
        jz .waitb
        mov dx, 0x3f8               ; Data Register
        in al, dx
        pop dx
        ret

buffer:
    times 256 db 0x90