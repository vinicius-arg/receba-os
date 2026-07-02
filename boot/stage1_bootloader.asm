; Fonte: https://medium.com/@sumeyyaaktas/part-1-writing-a-custom-x86-bootloader-with-ehci-support-from-scratch-43cb7a5b736d

; Constants
%define LOAD_ADDR      0x7c00
%define REALOC_ADDR    0x0600
%define REALOC_OFFSET  REALOC_ADDR - LOAD_ADDR
%define STACK_TOP      LOAD_ADDR
%define SECTOR_SIZE    512
%define STG2_ADDR      0x7e00
%define STG2_SECTORS   8

[org LOAD_ADDR]
[bits 16]

start:
    ; Cleaning state
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Configuring stack
    mov ss, ax
    mov sp, STACK_TOP

    ; Saving boot device drive
    mov [bootdrive], dl
    sti

    mov si, boot_init
    call print_string

    mov si, bd_saved
    call print_string

    ; Realocating bootloader to REALOC_ADDR
    mov si, LOAD_ADDR
    mov di, REALOC_ADDR
    mov cx, SECTOR_SIZE
    cld
    rep movsb
    jmp 0x0000: (continue_boot + REALOC_OFFSET)

continue_boot:
    mov si, mbr_realloc
    call print_string

    ; Reading stage 2 disk sectors
    mov al, STG2_SECTORS    ; Number of sectors to read
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [bootdrive + REALOC_OFFSET]
    mov bx, STG2_ADDR
    call read_sectors
    
    jmp 0x0000: STG2_ADDR

    ; Halt
    jmp $

; Variables
bootdrive db 0

; Strings
boot_init db    "Starting RecebaOS boot...", 0
bd_saved db     "Boot device drive saved into 0x0000.", 0
mbr_realloc db  "MBR reallocated to 0x0000.", 0

%include "./boot/print16.asm"
%include "./boot/disk_read.asm"

times 446 - ($ - $$) db 0
times 64 db 0
dw 0xaa55