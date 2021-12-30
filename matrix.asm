bits 16 ; tell NASM this is 16 bit code
org 0x7c00 ; tell NASM to start outputting stuff at offset 0x7c00

; https://stackoverflow.com/questions/47277702/custom-bootloader-booted-via-usb-drive-produces-incorrect-output-on-some-compute
jmp start
resb 0x50

col DW 0
PRN DW 54321
colsTtl db 40 dup 0
colsMode db 40 dup 0

start:
    mov ah,0x00 ; Set Video Mode
    mov al,0x13 ; http://www.techhelpmanual.com/114-video_modes.html
    int 0x10 ; runs BIOS interrupt 0x10 - Video Services

mainLoop:
    mov ah,0x07 ; Scroll down
    mov al,1    ; 1 Line
    mov bh,0
    mov ch,0
    mov cl,0
    mov dh,24d  ; rows
    mov dl,39d  ; cols
    int 0x10    ; runs BIOS interrupt 0x10 - Video Services

    mov ah,0x02 ; Set Cursor Position
    mov bh,0    ; video page number
    mov dh,0    ; row
    mov dl,0    ; column
    int 0x10    ; runs BIOS interrupt 0x10 - Video Services

    mov byte [col], 40
    .colLoop:
        mov si, [col]
        cmp byte [colsTtl + si], 0
        jg .noNewTtlRequired

        ; IF TTL == 0
        call    CalcNew                 ; -> AX is a random number
        xor     dx, dx
        mov     cx, 50
        div     cx                      ; here dx contains the remainder
        mov [colsTtl + si], dl          ; Assign new TTL (rand modulo 50)
        xor byte [colsMode + si], 0x01  ; Flip mode of the column

        .noNewTtlRequired:
        mov al, 0x20                ; Mode = 1 : print a space ' '
        cmp byte [colsMode + si], 1 ; Mode = 0 : print a rand char
        je .skipRandChar

        call calcrandchar

        .skipRandChar:
        call drawAl

        dec byte [colsTtl + si]     ; decrease TTL of the column

        dec byte [col] 
        jnz .colLoop

    call sleep

    jmp mainLoop

drawAl:
    mov ah,0x0e ; Write Character as TTY
    mov bl,2    ; color
    int 0x10    ; runs BIOS interrupt 0x10 - Video Services
    ret

sleep:
    xor dx,dx
    mov cx,0x0001
    mov ah,0x86
    int 0x15
    ret

; Returns the random char in AL
calcrandchar:
    call    CalcNew     ; -> AX is a random number
    xor     dx, dx
    mov     cx, 94
    div     cx          ; div ax/cx. Here dx contains the remainder
    add     dl, 32      ; add 32 to the random number (0-94) => (32-126)
    mov     al, dl
    ret

; Pseudo random generator https://stackoverflow.com/a/40709661
; inputs: none  (modifies PRN seed variable)
; clobbers: DX.  returns: AX = next random number
CalcNew:
    mov     ax, 25173       ; LCG Multiplier
    mul     word [PRN]      ; DX:AX = LCG multiplier * seed
    add     ax, 13849       ; Add LCG increment value
    ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
    mov     [PRN], ax       ; Update seed = return value
    ret

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!
