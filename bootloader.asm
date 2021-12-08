%define loc 0x1000
%define ftable 0x2000
%define drive 0x80
%define os_sect 3
%define ftabsect 2
[bits 16]
[org 0]

jmp 0x7c0:start

start:

	mov ax,cs
	mov ds,ax
	mov es,ax

	mov al,03h
	mov ah,0
	int 10h	


	mov si,msg
	call print

	mov ah,0
	int 16h

	mov si,msgw
	call print

	mov ax,loc
	mov es,ax
	mov cl,os_sect ; sector
	mov al,2 ; number of sectors

	call loadsector

	mov ax,ftable
	mov es,ax
	mov cl,ftabsect ; sector
	mov al,1 ; number of sectors

	call loadsector
	
    mov si, promptmessage
    call print

    call mainloop


mainloop:
    mov ah, 01h
    int 16h

    mov ah, 00h
    int 16h

    mov bl, 0x21
    mov ah,0x0e


    cmp al, 13 ; new line
    je nl

    ; one char buffer
    mov dl, al

    cmp al, 8 ; backspace
    je bs

    int 10h

    mov al, 8
    int 10h

    jmp mainloop


nl:

    mov al, 10
    int 10h
    mov al, 13
    int 10h


    ; commands

    cmp dl, 68h ; h
    je help

    cmp dl, 71h ; q
    je shutdown

    cmp dl, 72h ; r
    je reboot

    cmp dl, 2bh ; +
    je plus

    cmp dl, 2dh ; -
    je minus

    mov si, promptmessage
    call print

    jmp mainloop

bs:

    mov al, 32
    int 10h
    mov al, 8
    int 10h

    jmp mainloop


loadsector:
	mov bx,0
	mov dl,drive ; drive
	mov dh,0 ; head
	mov ch,0 ; track
	mov ah,2
	int 0x13
	jc err
	ret
err:
	mov si,erro
	call print
	ret
print:
	mov bp,sp
	cont:
	lodsb
	or al,al
	jz dne
	mov ah,0x0e
	mov bx,0
    
    ; colour
    mov bl, 0x21

	int 10h
	jmp cont
dne:
	mov sp,bp
	ret


times 510 - ($-$$) db 0
dw 0xaa55
msg db "Boot Complete.",10,13,"Welcome To ConOS! Press any key to continue.",10,13,10,13,0
msgw db "Press h for help.",10,13,10,13,0
helpmsg db "q to shutdown.",10,13,"r to reboot.",10,13,"+ to add.",10,13,"- to subtract.",10,13,0
erro db "Fatal Error Encountered...",10,13,"Error loading disk sector",10,13,0
promptmessage db "ConOS Prompt-$ ",0

; commands here
help:
    mov si, helpmsg
    mov byte dl, 0
    call print
    jmp nl

reboot:
    int 19h

shutdown:
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xf000 ; idk what the hell this all does but it works
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

plus:
    mov ah, 01h
    int 16h

    mov ah, 00h
    int 16h

    mov dl, al ; store first number in dl

    mov bl, 0x21
    mov ah,0x0e

    int 10h
    mov byte al, 32
    int 10h
    int 10h

    mov ah, 01h
    int 16h

    mov ah, 00h
    int 16h

    mov dh, al ; store second number in dh

    mov bl, 0x21
    mov ah,0x0e
    int 10h

    ; nl
    mov byte al, 10
    int 10h
    mov byte al, 13
    int 10h

    sub dl, 30h ; ascii to actual num
    sub dh, 30h

    add dl, dh ; add and output
    add dl, 30h
    mov al, dl
    int 10h

    mov byte dl, 0

    jmp nl


minus:
    mov ah, 01h
    int 16h

    mov ah, 00h
    int 16h

    mov dl, al ; store first number in dl

    mov bl, 0x21
    mov ah,0x0e

    int 10h
    mov byte al, 32
    int 10h
    int 10h

    mov ah, 01h
    int 16h

    mov ah, 00h
    int 16h

    mov dh, al ; store second number in dh

    mov bl, 0x21
    mov ah,0x0e
    int 10h

    ; nl
    mov byte al, 10
    int 10h
    mov byte al, 13
    int 10h

    sub dl, 30h ; ascii to actual num
    sub dh, 30h

    sub dl, dh ; add and output
    add dl, 30h
    mov al, dl
    int 10h

    mov byte dl, 0

    jmp nl