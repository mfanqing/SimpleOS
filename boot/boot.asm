[BITS 16]
[ORG 0x7C00]

start:
    cli
    cld
    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    mov [drive_num], dl
    
    mov si, msg_boot
    call print_string
    
    ; Load kernel to 0x1000:0000 (30 sectors starting from sector 2)
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    
    mov ah, 0x02
    mov al, 30              ; Read 30 sectors
    mov ch, 0               ; Cylinder 0
    mov cl, 2               ; Start sector 2
    mov dh, 0               ; Head 0
    mov dl, [drive_num]     ; Drive
    
    int 0x13
    
    mov si, msg_loaded
    call print_string
    
    ; Jump to kernel (0x1000:0000)
    jmp 0x1000:0x0000
    
print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print_string
.done:
    ret

drive_num: db 0x00
msg_boot db "SimpleOS Bootloader", 0x0D, 0x0A, 0
msg_loaded db "Entering kernel...", 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0
dw 0xAA55
