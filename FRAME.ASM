	
.model tiny
.code
org 100h
locals

;================================================
;               CONSTANTS

VIDEO equ 0b800h

HOR_SYM		= 0cdh
VER_SYM		= 0bah
COLOR       	= 04eh ;17h
HALF_LEN    	= 15d
CAL_NUM     	= 1d
HL          	= 0c9h
HR          	= 0bbh
LL          	= 0c8h
LR          	= 0bch
ESC_C       	= 1bh
ENTER_C     	= 0dh
BACK_C      	= 08h

.getch 	macro
	xor ah, ah
	int 16h
	endm

;================================================

Start:		
	mov ax, VIDEO 
	mov es, ax

        mov bx, (4d*80d + 40d - HALF_LEN)*2d
        
        call up_str
        
        mov cx, CAL_NUM
        
        call do_string

	call lw_str

        mov bx, (5d*80d+40d-HALF_LEN + 1)*2

        ExitWithESC:
        call do_text
        cmp al, ESC_C
        jne ExitWithESC
        
        ;mov ah, 1h
	;int 21h
		
	mov ax, 4c00h
	int 21h

;================================================
;               FUNCTIONS

do_text	proc
	
        .getch
        
        cmp al, ESC_C
        je fastRet

        cmp al, BACK_C
        je Backspase

        cmp al, ENTER_C
        jne symple  
        
        NewEmptyStr:
        inc now_height

        mov ax, bx
        mov dx, 0
        mov now_len, dx
        mov bx, 160d
        div bx

        ;ax частное, но вытянем al

        ;div ax, 160
        ;xor bl, bl
        mov bl, 160d
        mul bl
        
        mov bx, ax
        
        add bx, (80d+40d-HALF_LEN+1)*2d
        
        mov dx, now_height
        cmp dx, max_height
        jnbe expansion

        mov al, ' '
        ret
        
        symple:
        inc now_len
        
        mov byte ptr es:[bx], al
        mov byte ptr es:[bx+1], COLOR

        mov dx, now_len
        cmp dx, max_len
        je NewEmptyStr
        
        add bx, 2d
        
        fastRet:
        ret

        Backspase:
        mov ax, now_len
        cmp ax, 0h 
        je BackCal

        sub bx, 2
        mov byte ptr es:[bx], ' '
        mov byte ptr es:[bx+1], COLOR
        sub now_len, 1
        
        ret

                BackCal:

                sub bx, 160
                add bx, (HALF_LEN-3d)*4d+2d
                
                dec now_height

                mov byte ptr es:[bx], ' '
                mov byte ptr es:[bx+1], COLOR
                
                mov now_len, (HALF_LEN-2d)*2d-1d
                
                ret
        
        expansion:

        inc max_height
        ;sub bx, 2

        sub bx, 2d
        mov cx, (HALF_LEN-2d)*2D

        mov byte ptr es:[bx],    VER_SYM
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        @@DoStr:

	mov byte ptr es:[bx],    ' '
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        loop @@DoStr
        
        mov byte ptr es:[bx],    VER_SYM
	mov byte ptr es:[bx+1],  COLOR

        sub bx, (HALF_LEN-1)*4d
        add bx, 162d
    
        call lw_str
        
        sub bx, (HALF_LEN-2)*4d+160d

        ret
        endp

do_string   proc
        mov dx, (5d*80d + 40d - HALF_LEN)*2d
	mov bx, dx
        
        @@do_table:
        
        push cx
        mov cx, (HALF_LEN-2d)*2d
        
        mov byte ptr es:[bx],    VER_SYM
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        @@DoStr:

	mov byte ptr es:[bx],    ' '
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        loop @@DoStr
        
        mov byte ptr es:[bx],    VER_SYM
	mov byte ptr es:[bx+1],  COLOR

        pop cx
        add dx, 160d
        mov bx, dx
        
        loop @@do_table

        ;sub dx, 160d

        mov bx, dx

        ret
        endp

up_str  proc
        
        mov byte ptr es:[bx],    HL
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        mov cx, (HALF_LEN-2d)*2d
        
         @@DoStr:

	mov byte ptr es:[bx],    HOR_SYM
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        loop  @@DoStr
        
        mov byte ptr es:[bx],    HR
	mov byte ptr es:[bx+1],  COLOR
        
        ret
        endp

lw_str  proc
        
        mov byte ptr es:[bx],    LL
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        mov cx, (HALF_LEN-2d)*2d
        
        @@DoStr:

	mov byte ptr es:[bx],    HOR_SYM
	mov byte ptr es:[bx+1],  COLOR
        add bx, 2d

        loop @@DoStr
        
        mov byte ptr es:[bx],    LR
	mov byte ptr es:[bx+1],  COLOR
            
        ret
        endp

;================================================
;               VARIABLES

.data

max_height  dw CAL_NUM
max_len     dw (HALF_LEN-2d)*2d
now_height  dw 1d
now_len     dw 0d

end Start
