[org 0x7e00]
[bits 16]

%define KERNEL_OFFSET       0x1000
%define KERNEL_SEGMENT      0x0000
%define KERNEL_SECTORS      16
%define VGA_3RDLINE_OFFSET  480

start_stg2:
    mov [bootdrive], dl

    ; mov bx, real_mode_str
    ; ...

    call enable_a20

    ; mov bx, loading_kernel_str
    ; ...

    ; Loading kernel
    ; 3-try retry mechanism
    mov cx, 3

load_kernel:
    push cx

    mov ax, KERNEL_SEGMENT
    mov es, ax
    mov bx, KERNEL_OFFSET

    ; Reading kernel disk sector
    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov ch, 0
    mov cl, 10 ; Reading at sector 10
    mov dh, 0
    mov dl, [bootdrive]
    int 0x13

    pop cx
    jnc .kernel_load_success

    ; mov bx, retry
    ; ...

    loop load_kernel

enable_a20:
    pushad
    in al, 0x92
    or al, 2
    out 0x92, al
    popa
    ret

.kernel_load_success:
    ; Sanity check
    mov ax, [KERNEL_OFFSET]
    cmp ax, 0
    je .kernel_load_error

    ; mov bx, kernel_loaded_str
    ; ...

    ; Finishing kernel loading
    mov dword [cursor_pos], VGA_3RDLINE_OFFSET
    call switch_to_pm

.kernel_load_error:
    mov si, kernel_lerror_msg
    call print_string
    jmp $ ; Halt

[bits 32]

begin_pm:
    ; mov ebx, pm_str
    ; ...

    ; mov ebx, jumping_kernel_str
    ; ...

    jmp CODE_SEG:KERNEL_OFFSET

%include "./boot/switch_to_pm.asm"

; Variables
cursor_pos dd 0

; Strings
kernel_lerror_msg db "Error while trying to load the kernel."

times 4096 - ($ - $$) db 0
