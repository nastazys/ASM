.model small   
.stack 100h
.data 
 
     noDataStr db "No data!", '$'
    noFileStr db "The file with this name doesn't exist!", '$'
    procStartStr db "File processing has started...", '$'
    amountStr db "The amount of non-empty lines is:", 9h, '$'  
    procFinStr db "File processing has finished.", '$'
	finStr db "Program executed successfully.", '$'
	addAmountStr db " additional amount:", 9h, '$' 
    endl db 0Dh, 0Ah, '$'
    
    sucMessage1 db "FOPEN: Success!", '$'
    sucMessage2 db "FCLOSE: Success!", '$'
    sucMessage3 db "CEL: RFF: Success!", '$'  
    notEqualMessage db "Files are not equal!", '$'       
    equalMessage db "Files are equal!", '$'
    sucMessage5 db "CEL: Success!", '$' 
    sucMessage6 db "PR: Success!", '$'
        
    errMessage1 db "FOPEN: File not found!", '$' 
    errMessage2 db "FOPEN: Path not found!", '$'
    errMessage3 db "FOPEN: Too many files are opened!", '$'
    errMessage4 db "FOPEN: Access denied!", '$'
    errMessage5 db "FOPEN: Wrong access mode!", '$'  
    errMessage6 db "FCLOSE: Wrong descryptor!", '$'
    errMessage7 db "CEL: RFF: error!", '$'  
    errMessage8 db "CEL: SB: error!", '$' 
    errMessage9 db "PR: error!", '$'

    maxF1NameLen equ 126
    F1NameLen dw ? 
    F1Name db 126 dup(?)     
    
    ;maxF2NameLen equ 126
    ;F2NameLen dw ? 
    ;F2Name db 126 dup(?) 
    F2Name db "file2.txt", 0 
    
    file1Descr dw ? 
    file2Descr dw ?      
    buf1Size equ 50
    buf1 db buf1Size+2 dup('$')     
    buf2Size equ 50
    buf2 db buf2Size+2 dup('$') 
    
    chars dw 0    
    cf dw 0 
    eof dw 0   
    equf dw 0
.code  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;MACROS;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
display macro string
    pusha
    displaySingle string
    displaySingle endl
    popa
endm 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
displaySingle macro string
    lea dx, string
    mov ah, 09h
    int 21h
endm 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro exit
   mov ax,4C00h
   int 21h  
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;MAIN;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
main: 
    mov ax, @data
    mov ds, ax    
    
    call getComArgs    
    cmp F1NameLen, 1
    jle noData          
    
    display procStartStr
    lea dx, F1Name
    call fopen
    cmp ax, 1
    je endMain              
    mov file1Descr, ax ; copy desc
    
    lea dx, F2Name
    call fopen
    cmp ax, 1
    je endMain              
    mov file2Descr, ax ; copy desc
    
    display sucMessage1
    call filesCmp
    
    mov bx, file1Descr
    call fclose
    
    mov bx, file2Descr
    call fclose
     
    jmp endMain
noData: 
    display noDataStr   
endMain:
    exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;;;;;;;;;;;;;;;PROCEDURES;;;;;;;;;;;;;;;;;                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getComArgs proc 
    ;returns: operation code in ax (0 - ok, 1 - no args)
    push ax
    push cx
    
    mov cx, 0
	mov cl, es:[80h]	;80h - cmd length	
	mov F1NameLen, cx
	cmp cx, 1
	jle endGCA 		           
    
	cld
	mov di, 81h         ;81h - cmd itself
	mov al, ' '
	rep scasb   ;repeat send byte while not end
	dec di
	
	lea si, F1Name
skip:
    mov al,es:[di]
    cmp al, 0dh ;/r?
    je endSkip
    cmp al, 20h ;space?
    je endSkip 
    cmp al, 9h  ;tab?
    je endSkip
    mov ds:[si], al 
    inc di
    inc si
    jmp skip  
       	
endSkip:
    inc si
    mov ds:[si], word ptr '$'   
             
endGCA:
    pop cx
    pop ax    
    ret
endp getComArgs       


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
fopen proc
; requires: ds:dx - file name
; returns:  ax - operation code (0 - ok, 1 - error)
;           fileDescr - file descr

    push cx 

    mov ah, 3dh
    mov al, 0h  ; 0 000 00 0 0b : compatability mode
    int 21h
        
    jc errorHandling ; if errors occured, handle them 
    
    ;mov fileDescr, ax ; copy desc
    jmp fopenOk
    
errorHandling:

    cmp al, 02h
    jne pathNotFound
    display errMessage1
    jmp fopenError
    
pathNotFound:

    cmp al, 03h
    jne tooManyFilesOpened 
    display errMessage2
    jmp fopenError
    
tooManyFilesOpened:
                        
    cmp al, 04h
    jne accessDenied 
    display errMessage3
    jmp fopenError
    
accessDenied:

    cmp al, 05h
    jne wrongAccessMode 
    display errMessage4
    jmp fopenError
    
wrongAccessMode:

    cmp al, 0Ch
    jne fopenError
    display errMessage5
    jmp fopenError
     
fopenOk:
    mov ax, 0 
    jmp fopenEnd
fopenError: 
    mov ax, 1
fopenEnd:
    pop cx    
    ret 
fopen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fclose proc
; requires: bx - file descr 
    ;mov bx, fileDescr
    mov ah, 3eh
    int 21h ;  
    
    jnc fcloseOk   
    
;   display errMessage6 
    mov ax, 1
    jmp fcloseFin 
    
fcloseOk :
    mov ax, 0 
;   display sucMessage2
fcloseFin:
    ret
fclose endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
filesCmp proc 
    pusha
    
handling:    
    mov bx, file1Descr
    lea dx, buf1
    call readFromFile ; fill buffer  
    cmp ax, 1
    je finCmp
    mov bx, file2Descr  
    lea dx, buf2
    call readFromFile ; fill buffer
    cmp ax, 1
    je finCmp        
    
    cmp cx, buf1Size   ; cx<bufSize -> not enough chars
    jb lastOperation  ; to fill the buf -> end of file

    call scanBuf      ; 
    cmp ax, 0
    jne notEquals0
    
    jmp handling

lastOperation:
    mov eof, 1
    call scanBuf   
    cmp ax, 0
    jne notEquals0
    jmp finCmp 
notEquals0:
    mov equf, 1   
    jmp finCmp
finCmp: 
    popa
    ret
filesCmp endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readFromFile proc  
;requires: bx - file descr
;returns:  ax - operation code (0 - ok, 1 - error)
;          cx - amount of read bytes
    mov ax, 0
    mov ah, 3fh
    mov cx, 50 ; read 50 bytes if possible
    ;lea dx, buf 
    int 21h
    
    jc FRRerror 
    
    mov cx, ax
    mov ax, 0
;   display sucMessage3
    jmp FRRend

FRRerror:
    display errMessage7
    mov ax, 1

FRRend:
    ret
readFromFile endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
scanBuf proc
scan:      
    lea si, buf1
    lodsb ; load character
    
    mov bx, ax
    
    lea si, buf2
    lodsb ; load character  
      
    cmp al, bl  
    je notEqual 
    
    mov ax, 0 
    display equalMessage
    jmp finScan
     
notEqual:
    display notEqualMessage 
finScan:
    ret
scanBuf endp  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end main