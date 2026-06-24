; Print a single char stored in AL
print_char:
    mov ah, 0x0e    ; Set teletype video mode
    int 0x10        ; Call BIOS video interrupt
    ret

; Print a whole null-terminated string stored in DS:SI
print_string:
    .print_loop:
        lodsb             ; Loads a string from SI into AL and incs index
        cmp al, 0         ; Checks null terminator
        je .done
        call print_char
        jmp .print_loop

    .done:
        ret