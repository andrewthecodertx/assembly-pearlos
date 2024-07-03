[bits 16]
[org 0x7c00]

%define ENDL 0x0d, 0x0a

jmp start

; BIOS Parameter Block
bdb_oem:                    db 'MSWIN4.1'
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1 
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0e0h
bdb_total_sectors:          dw 2880
bdb_media_description_type: db 0f0h
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; Extended Boot Record
ebr_drive_number:           db 0
                            db 0
ebr_signature:              db 29h
ebr_volume_id:              db 66h, 66h, 66h, 66h
ebr_volume_label:           db 'PearlOS 0.1'
ebr_system_id:              db 'FAT12   '

start:
    cli
    cld

    ; Load kernel (assuming it starts at sector 2)
    mov bx, 0x1000  ; Address to load the kernel
    mov dh, 1       ; Number of sectors to load
    mov dl, [ebr_drive_number]
    mov si, 0x0200  ; Starting sector (sector 2)
    call diskread

    ; Set up protected mode
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Jump to protected mode kernel entry point
    jmp 08h:0x1000

puts:
    push si
    push ax

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0e
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret

main:
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; Setup stack
    mov ss, ax
    mov sp, 0x7c00
    mov [ebr_drive_number], dl
    mov ax, 1
    mov cl, 1
    mov bx, 0x7e00

    call diskread

    ; Print startup message to screen
    mov si, msg_startup
    call puts

    ; Print some more stuff
    mov si, msg_author
    call puts

    cli                 ; Disable interrupts
    hlt

floppyerror:
    mov si, msg_floppy_failed
    call puts
    jmp reboot

reboot:
    mov ah, 0
    int 16h
    jmp 0ffffh:0        ; Beginning of BIOS

.halt:
    cli                 ; Disable interrupts
    hlt

lbatochs:
    push ax
    push dx
    
    xor dx, dx
    div word [bdb_sectors_per_track]

    inc dx
    mov cx, dx

    xor dx, dx
    div word [bdb_heads]

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov dl, al
    pop ax

    ret

diskread:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx
    call lbatochs
    pop ax

    mov ah, 02h
    mov di, 3       ; Retry the conversion 3 times. Suggested in FAT documentation

.retry:
    pusha
    stc
    int 13h
    jnc .done

    ; Failure, print debug message
    mov si, msg_debug_disk_read_fail
    call puts

    popa
    call reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppyerror

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    ret

reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppyerror
    popa

    ret

gdt_start:
    dq 0x0000000000000000
    dq 0x00cf9a000000ffff  ; Code segment descriptor
    dq 0x00cf92000000ffff  ; Data segment descriptor
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

msg_startup:                db 'Welcome to PearlOS', ENDL, 0
msg_author:                 db 'A simple bootloader by Andrew S Erwin', ENDL, 0
msg_floppy_failed:          db 'I could not read from the disk!', ENDL, 0
msg_debug_disk_read_fail:   db 'Disk read failed!', ENDL, 0

times 510-($-$$) db 0
dw 0xaa55
