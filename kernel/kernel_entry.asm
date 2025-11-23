[BITS 32]

extern kernel_main

section .text
    global start

start:
    cli                          ; Clear interrupts
    
    ; Set up stack FIRST (critical!)
    mov esp, 0x90000            ; Stack pointer (above kernel space)
    mov ebp, esp
    
    ; Direct VGA test - write to first position
    mov eax, 0xB8000            ; VGA memory address
    mov byte [eax], 'K'         ; Write 'K'
    mov byte [eax+1], 0x0F      ; Attribute: white on black
    
    ; Call C kernel function
    call kernel_main
    
    ; If kernel_main returns, halt
    cli
    hlt
    jmp $                        ; Infinite loop as fallback
