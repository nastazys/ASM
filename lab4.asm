.model small
.stack 100h         

; вывод новой строки
new_line macro
    mov ah, 2
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h
endm

; очистка экрана
clrscr macro
    mov ah, 6
    xor al, al     ; прокрутка всего экрана с заполнением пробелами(очистка)
    xor cx, cx     ; строка и столбец верхнего левого угла экрана
    mov dx, 184fh  ; строка и столбец нижнего левого угла окна
    mov bh, 7      ; атрибут вставляемого символа
    int 10h        ; прокрутка экрана вверх (вставка чистых строк снизу), AH = 6
endm

; переместить курсор вправо
movcursor_r macro
    mov ah, 3
    xor bh, bh     ; номер страницы = 0
    int 10h        ; получить положение и размер курсора, AH = 3

    mov ah, 2
    inc dl         ; в DL - столбец текущей позиции курсора
    int 10h        ; установить положение курсора, AH = 2
endm

; переместить курсор влево
movcursor_l macro
    mov ah, 3
    xor bh, bh
    int 10h

    mov ah, 2
    dec dl
    int 10h
endm

; переместить курсор в заданное положение
setcursor macro r, c
    mov ah, 2
    xor bh, bh     ; номер страницы = 0
    mov dh, r      ; номер строки
    mov dl, c      ; номер столбца
    int 10h        ; установить положение курсора, AH = 2
endm

nums macro lp1, lp2, lp3, lp4, cnt, outs, val
numbers:
    mov cx, 4
    mov dl, val
    cmp dl, 0
    je lp4:

    mov ax, 1
    mov cx, 0
    mov cl, dl
    sub cl, 'a'
    add cl, 1
    sal ax, cl

    mov len, 0
    mov bl, 10
lp1:
	div bl

	mov cx, 0
	mov cl, ah
	add cl, 48
	push cx
	add len, 1
	mov ah, 0
	cmp al, 0
	jne lp1


	mov al, 4
	sub al, len
	cmp al, 0
	je cnt

	mov cx, 0
	mov cl, al
	mov ah, 2
	mov dl, ' '
lp2:
    int 21h
    loop lp2
cnt:
lp3:
	sub len, 1
	pop ax
	mov ah, 9
	xor bh, bh
	mov cx, 1
	mov bl, 34h
	int 10h
	movcursor_r
	cmp len, 0
	jne lp3

	mov dl, ' '
	int 21h
	jmp outs

	mov cx, 4
lp4:
	mov ah, 2
	mov dl, ' '
	int 21h
	loop lp4
    int 21h
outs:
endm

; вывод очков счёта на экран
macro c_score

   mov ax, score
   mov dx, 0
   mov bx, 10

   mov len, 0

l1:
    mov dx, 0
    div bx
    push dx
    add len, 1
    cmp ax, 0
    jne l1

	setcursor 23, 25
	mov ah, 9
	lea dx, str7
	int 21h

l2:
    pop dx
    add dl, 48
    sub len, 1
    mov ah, 2
    int 21h
    cmp len, 0
    jne l2
endm

; вывод 10 подчёркиваний
macro underline
    mov len, 10
und:
	sub len, 1
	mov ah, 2
	mov dl, '_'
	int 21h
	cmp len, 0
	jne und
endm

; вывод 10 пробелов
macro ununderline unund
    mov len, 10
unund:
	sub len, 1
	mov ah, 2
	mov dl, ' '
	int 21h
	cmp len, 0
	jne unund
endm

; задержка экрана для анимации вывода текста
macro cool g1, g2, g3, e1, str
    lea si, str
g1:
	mov dl, [si]
	cmp dl, '$'
	je e1
	mov tmp1,dl
	mov tmp2, dl
	mov len, 12
	mov dl, tmp1
g2:
	dec len
	inc tmp1
	mov al, tmp1
	mov cx, 1
	mov ah, 9h
	int 10h
	mov cx, 30000
g3:
	loop g3
	cmp len, 0
	jne g2

	mov al, tmp2
	mov cx, 1
	mov ah, 9h
	int 10h
	movcursor_r
	inc si
	jmp g1
e1:
endm

.data
arr db 17 dup(0)
beg db 0
score dw 0
tsc dw 1
calc db 0
userin db ?
csr db 0		; позиция курсора в ряду
csc db 0 		; позиция курсора в столбце
len db 0
tmp dw ?
tmp1 db ?
tmp2 db ?
tmp3 db ?
flag db 'a'
flag2 db 0
done db 0
choise db 0     ; выбор в меню
mode db 0
str1 db "you lose...$"
str2 db "you are a winner!$"
str3 db "l = left, r = right, u = up, d = down"
str4 db "2048 game $"
str5 db "game ended... press esc$"
str6 db "press esc for menu$"
str7 db "score: $"
str8 db "** 2048 **$"
str9 db "play$"
str11 db "exit$"
strz db 2 dup("$")

.code
main proc
    mov ax, @data
    mov ds, ax

setwindow:				;set window size to 40*25
	mov ah, 0           
	mov al, 1           ;AL = 1: текст 40x25 16/8 CGA,EGA  b800  Comp,RGB,Enhanced
	int 10h             ;установка видео режима с RGB и размером экрана 40x25, AH = 0

initialize:				;print home page
	mov score, 0 
    mov ah, 9
	mov al, ' '         ;символ
	xor bh, bh 			;set text colour for str8
	mov bl, 10          ;symbol atribute
	mov cx, 200         ;число повторений символа
	int 10h             ;вывести символ с текущим атрибутом на экран, AH = 9

    setcursor 4, 14
    cool pp1, pp2, pp3, pp4, str8
    setcursor 8, 10

    mov ah, 9
	mov al, ' '
	xor bh, bh 			;set text colour for str9
	mov bl, 15
	mov cx, 251
	int 10h

    mov ah, 9
    lea dx, str9
    int 21h

    setcursor 16, 10

    mov ah,9
	mov al, ' '
	xor bh, bh
	mov bl, 12
	mov cx, 100			;set text colour for str11
	int 10h
    mov ah, 9
    lea dx, str11
    int 21h

    mov csr, 9
    setcursor csr, 10
    mov choise, 1

menu:					;create the menu
	setcursor csr, 10
	underline			;underline current selection
	mov ah, 0
	int 16h

	cmp ah, 50h 		;down
	je lower
	cmp ah, 48h 		;up
	je upper
	cmp ah, 1ch
	je background
	jmp menu

lower:					;moves underline lower if possible
	cmp csr, 17
	je menu
	setcursor csr, 10
	ununderline t1
	add csr, 8
	add choise, 1 		;determines the selection
	setcursor csr, 10
	jmp menu
upper:					;moves undrline upper if possible
	cmp csr, 9
	je menu
	setcursor csr, 10
	ununderline t2
	sub csr, 8
	sub choise, 1 		;determines the selection
	setcursor csr, 10
	jmp menu

background:				;set background
	cmp choise, 2
	je exit

    mov ah, 6
    mov cx, 0
    mov dh, 24
    mov dl, 39
    mov bh, 31h         ; красим экран в голубой цвет
    mov al, 0
    int 10h             ; очистка экрана, AH = 6, AL = 0

    lea si, arr
    mov cx, 17
set_0:					;reset array to zero
	mov [si], 0
	inc si
	loop set_0

begin:					;game begins
	mov ah, 2ch			;get the time
	int 21h

randomize:				;selects random position and value
	mov ax, 0
	mov al, dl			;ax has miliseconds
	mov dl, 16
	div dl				;this causes remainder to be within 0 ot 15
	mov beg, ah			;beg has the remainder

	shr ah, 1 			;if remainder is odd 2 will appear else 4 will appear
	jc four

	mov flag, 'a'
	jmp searching

four:
	mov flag, 'b'

searching:				;searching for empty position
	lea si, arr			;starting from the position
	mov ax, 0			;represented by beg
	mov al, beg
	add ax, 1			;adding 1 so position will be in 1 to 16
	add si, ax

	mov cx, 16
round:
	cmp [si], 0
	je placeval

	cmp si, 16
	jne noreset
reset:
	lea si, arr
	inc si
	jmp last

noreset:
    inc si
last:
    loop round
    jmp next

placeval:				;places value in [si]
	mov dl, flag
	mov [si], dl
	jmp next

next:
grid:					;prints the grid
	mov tmp1, 5
	mov csr, 0
grow:
	sub tmp1, 1
	setcursor csr, 0
	mov cx, 39
gcol:
	mov ah, 2
	mov dl, 220;;
	int 21h
	loop gcol
	add csr, 5
	cmp tmp1, 0
	jne grow

	mov tmp1, 5
	mov csc, 1
gcol2:
	sub tmp1, 1
	mov csr, 0
	setcursor csr, csc
	mov cx, 22
grow2:
	mov ah, 2
	mov dl, 221;;
	int 21h
	add csr, 1
	setcursor csr, csc
	loop grow2
	add csc, 9
	cmp tmp1, 0
	jne gcol2

print:					;prints the numbers in the grid
    lea si, arr
    inc si
    mov tmp2, 4
    mov ah, 2
    mov tmp1, 0
    mov flag, 0
    mov csr, 3
rowp:
	sub tmp2, 1
	mov tmp3, 4
	mov csc, 4

column:
	sub tmp3, 1
	mov dl, [si]
	mov done, dl
	cmp dl, 0
	jne cont1
	mov flag, 1				;checks for empty position

cont1:
	cmp dl, 'k'				;winning condition
	jne cont2
	mov tmp1, 'k'

cont2:
	setcursor csr, csc
	nums p1, p2, p3, p4, c1, o2, done
	inc si
	add csc, 9
	cmp tmp3, 0
	jne column
	new_line
	add csr, 5
	cmp tmp2, 0
	jne rowp
    new_line
    c_score					;print score

    cmp tmp1, 'k'			;checks winning condition
    je win

    mov ah, flag			;checks losing condition
    cmp ah, 1
    jne lose

input:						;takes user input
    setcursor 23, 0
    mov done, 0
    mov ah, 0
    int 16h
    mov userin, ah

    cmp userin, 4bh			;left
    jne next1

left:
	mov cx, 4
	mov bx, 1
rowsl:
	lea si, arr
	add si, bx
	add bx, 4

	mov di, si
	inc di

	mov dl, 3
whilel:
	mov al, [si]
	mov ah, [di]
	cmp si, di
	je noworkl
	cmp ah, 0
	jne workl
noworkl:
	inc di
	dec dl
	jmp end_workl

workl:
	cmp al, 0
	je replacel

	noreplacel:
	cmp al, ah
	je mergel
nomergel:
	inc si
	jmp end_workl

mergel:
	mov done, 1

	mov tmp1, al
	mov tsc, 1
	mov calc, al
	sub calc, 'a'
	add calc, 1
shiftl:
	dec calc
	shl tsc, 1
	cmp calc, 0
	jne shiftl
	mov ax, tsc
	add score, ax
	add score, ax

	mov al, tmp1
	inc al
	mov [si], al
	mov [di], 0
	inc si
	inc di
	dec dl
	jmp end_workl

replacel:
	mov done, 1
	mov [si], ah
	mov [di], 0

end_workl:

	cmp dl, 0
	je end_whilel
	jmp whilel ;loop
end_whilel:
    loop rowsl
    cmp done, 0
    je print
    jmp begin

next1:
    cmp userin, 4dh         ;right
    jne next2
right:
	mov cx, 4
	mov bx, 4
rowsr:

	lea si, arr
	add si, bx
	add bx, 4

	mov di, si
	dec di

	mov dl, 3
whiler:
	mov al, [si]
	mov ah, [di]
	cmp si, di
	je noworkr
	cmp ah, 0
	jne workr

noworkr:
	dec di
	dec dl
	jmp end_workr
workr:
	cmp al, 0
	je replacer

noreplacer:
	cmp al, ah
	je merger

nomerger:
	dec si
	jmp end_workr

merger:
	mov done, 1

	mov tmp1, al
	mov tsc, 1
	mov calc, al
	sub calc, 'a'
	add calc, 1
shiftr:
	dec calc
	shl tsc, 1
	cmp calc, 0
	jne shiftr
	mov ax, tsc
	add score, ax
	add score, ax

	mov al, tmp1

	inc al
	mov [si], al
	mov [di], 0
	dec si
	dec di
	dec dl
	jmp end_workr

replacer:
	mov done, 1
	mov [si], ah
	mov [di], 0

	end_workr:
	cmp dl, 0
	je end_whiler
	jmp whiler

end_whiler:
    loop rowsr
    cmp done, 0
    je print

    jmp begin

next2:
    cmp userin, 48h         ;up
    jne next3
up:
	mov cx, 4
	mov bx, 1
rowsu:
	lea si, arr
	add si, bx
	add bx, 1

	mov di, si
	add di, 4

	mov dl, 3
whileu:
	mov al, [si]
	mov ah, [di]
	cmp si, di
	je noworku
	cmp ah, 0
	jne worku

noworku:
	add di, 4
	dec dl
	jmp end_worku

worku:
	cmp al, 0
	je replaceu

noreplaceu:
	cmp al, ah
	je mergeu
nomergeu:
	add si, 4
	jmp end_worku
mergeu:
	mov done, 1
	mov tmp1, al
	mov tsc, 1
	mov calc, al
	sub calc, 'a'
	add calc, 1
shiftu:
	dec calc
	shl tsc, 1
	cmp calc, 0
	jne shiftu
	mov ax, tsc
	add score, ax
	add score, ax

	mov al, tmp1

	inc al
	mov [si], al
	mov [di], 0
	add si, 4
	add di, 4
	dec dl
	jmp end_worku

replaceu:
	mov done, 1
	mov [si], ah
	mov [di], 0

end_worku:
	cmp dl, 0
	je end_whileu
	jmp whileu

end_whileu:
	loop rowsu
	cmp done, 0
    je print
    jmp begin

next3:
	cmp userin, 50h         ;down
	jne next4
down:
	mov cx, 4
	mov bx, 13
rowsd:
	lea si, arr
	add si, bx
	add bx, 1

	mov di, si
	sub di, 4
    mov dl, 3
whiled:
	mov al, [si]
	mov ah, [di]
	cmp si, di
	je noworkd
	cmp ah, 0
	jne workd
noworkd:
	sub di, 4
	dec dl
	jmp end_workd

workd:
	cmp al, 0
	je replaced

noreplaced:
	cmp al, ah
	je merged

nomerged:
	sub si, 4
	jmp end_workd

merged:
	mov done, 1

	mov tmp1, al
	mov tsc, 1
	mov calc, al
	sub calc, 'a'
	add calc, 1
shiftd:
	dec calc
	shl tsc, 1
	cmp calc, 0
	jne shiftd
	mov ax, tsc
	add score, ax
	add score, ax

	mov al, tmp1

	inc al
	mov [si], al
	mov [di], 0
	sub si, 4
	sub di, 4
	dec dl
	jmp end_workd

replaced:
	mov done, 1
	mov [si], ah
	mov [di], 0

end_workd:
	cmp dl, 0
	je end_whiled
	jmp whiled

end_whiled:
	loop rowsd
	cmp done, 0
	je print
	jmp begin
next4:					    ;user doesn't want to play :(
	cmp userin, 01h
	jne next5
	clrscr
	jmp initialize
next5:					    ;invalid input
    jmp input

lose:
	setcursor 10, 8
	cool z1, z2, z3, z4, str5
	mov ah, 0
	int 16h
	cmp ah, 01h
	jne lose

	clrscr
lose1:
	mov bx, 6
	mov csr, 10
	mov csc, 14
	setcursor csr, csc
	cool q1, q2, q3, q4, str1
	mov ah, 0
	int 16h
	cmp ah, 01h
	jne lose1
	clrscr
	jmp initialize

win:
	setcursor 10, 8
	cool y1, y2, y3, y4, str5
	mov ah, 0
	int 16h
	cmp ah, 01h
	jne win
	clrscr
win1:
	lea di, str2
	mov bx, 5
	mov csr, 5
	mov csc, 10
	setcursor csr, csc

msg1:
    cmp [di], '$'
    je end_msg1
    mov al, [di]
    lea si, strz
    mov [si], al
    cool x1, x2, x3, x4, strz
    inc bx
    inc di
    cmp bx, 16
    jne msg1
    mov bx, 10
    jmp msg1
end_msg1:
    mov ah, 0
    int 16h
    cmp ah, 01h
    jne win1
    clrscr
    jmp initialize
exit:
    clrscr
    mov ah,4ch
    int 21h
    main endp

end main
