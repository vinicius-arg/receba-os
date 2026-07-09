read_sectors:
    mov ah, 0x02
    int 0x13
    jc read_sector.fail

    mov si, disk_read
    call print_string

    ret

read_sector:
    mov ah, 0x02
    mov al, 0x01
    int 0x13
    jc .fail

    mov si, disk_read
    call print_string

    ret

    .fail:
        mov si, read_error
        call print_string
        jmp $

disk_read db   "Reading disk sectors at 0x0000", 0
read_error db  "Disk read error.", 0