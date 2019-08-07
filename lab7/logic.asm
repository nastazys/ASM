.model	small
.stack	100h  

.data
start_msg                   db  0Dh,'Enter string A1 X A2 X A3 (max A - 99): $' 
error_msg                   db  0Dh,'Bad input, enter again! $'
endl_msg                    db  0Ah, 0Dh, '$'
base_str                    db 202,202 dup ('$')          
buffer                      dw  ?    
last_num                    dw  ?  
last_oper                   db  ?  
two                         equ 2       

epb dw ?
dw 0     
run_adr dw 0
run_seg dw ?
pathAdd db "OVERADD.exe", 0         
pathSub db "OVERSUB.exe", 0   
pathMul db "OVERMUL.exe", 0    
pathDiv db "OVERDIV.exe", 0     

.code

;lea dx str
showMsg proc
    push ax   
    push dx
    
    lea dx, endl_msg
      
    mov ah,09h                               
    int 21h 
    
    pop dx
    
    mov ah,09h                               
    int 21h  
    
    pop ax
     
    ret
showMsg endp 

inpStr proc         
    push ax
    mov ah,0ah
    int 21h   
    pop ax
    
    ret 
inpStr endp   

checkSym proc 
    cmp al, '+'
    je opPlus   
    
    cmp al, '-'
    je opMinus
    
    cmp al, '*'
    je opMul
    
    cmp al, '/'
    je opDiv
                       
    cmp al,'9'                    
    ja errCheckSym               

    cmp al,'0'                    
    jb errCheckSym               
    
    jmp exitCheckGood               
                                  
    errCheckSym:                  
        mov ah,1                  
        jmp exitCheckSym    
        
    opPlus:                  
        mov ah,2                  
        jmp exitCheckOper  
        
    opMinus:                  
        mov ah,3                  
        jmp exitCheckOper  
        
    opMul:                  
        mov ah,4                  
        jmp exitCheckOper  
        
    opDiv:                  
        mov ah,5                  
        jmp exitCheckOper           
                                  
    exitCheckGood:                
        xor ah,ah 
        jmp exitCheckSym
        
    exitCheckOper:  
        mov bh,ah
        call calculate   
        mov bl, 1        
                                  
    exitCheckSym:                 
        ret 
checkSym endp   

calculate proc 
    cmp last_oper, 2
    jge go      
    
    mov last_oper, ah  
    mov ax, buffer  
    mov last_num, ax     
    mov buffer, 0 
    jmp exitCalc
    
    go:        
    push bx
    mov ax, last_num 
    
    cmp last_oper, 2 
    je plus
    
    cmp last_oper, 3 
    je minus    
                
    cmp last_oper, 4 
    je multipl
    
    cmp last_oper, 5 
    je diver
    
    plus:
        mov dx, offset pathAdd
        jmp endCalc     
        
    minus:
        mov dx, offset pathSub 
        jmp endCalc    
        
    multipl:
        mov dx, offset pathMul
        jmp endCalc 
        
    diver: 
        mov dx, offset pathDiv 
        
    endCalc:      
    push ax  
    mov cx, buffer   

mov bx, offset EPB 
mov ax, 4B03h 
int 21h       

pop ax
 


call dword ptr run_adr    
       
        pop bx
        mov last_num, ax 
        mov last_oper, bh   
        mov buffer, 0
    
    exitCalc:  
       
    ret
calculate endp

;al - num     
outNum proc    
    lea dx, endl_msg
    call showMsg
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
 
        mov     cx, 10
        xor     di, di          
 
        or      ax, ax
        jns     convert
        push    ax
        mov     dx, '-'
        mov     ah, two           
        int     21h
        pop     ax
 
        neg     ax
 
convert:
        xor     dx, dx
        div     cx              
        add     dl, '0'         
        inc     di
        push    dx             
        or      ax, ax
        jnz     convert
        
print:
        pop     dx              
        mov     ah, two           
        int     21h
        dec     di              
        jnz     print
 
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
outNum endp   
    

start:

mov	ax,@data                      
mov	ds,ax 

mov ax, zzz
mov dx, es 
sub ax, dx 
mov  bx, ax
mov ah, 4ah
int 21h        
 
mov ah, 48h  
mov bx, 1000h      
int 21h     
 
mov EPB, ax  
mov EPB+2, ax 
mov run_seg, ax 
mov ax, ds
mov es, ax 
          
beg:           
lea dx, start_msg
call showMsg  

lea dx, base_str
call inpStr

mov si, offset base_str+2       
mov bl, 1
inputLoop:       
    cld               
    lodsb              
    
    cmp al, 0dh
    je finCalc
    
    xor bh, bh
    call checkSym 
    
    cmp bh, 2
    jge erCheck
    
    push ax
    mov ax, buffer
    mul bl         
    mov buffer, ax
    pop ax              
    
    sub al, '0'
    xor ah, ah
    add buffer, ax
    
    mov al,bl          
    mov bl,10             
    mul bl
    mov bl, al      
    
    erCheck:        
    cmp ah, 1
    je errorInput
    
    jmp nextSym
            
errorInput:      
    lea dx, error_msg
    call showMsg
    jmp beg         
    
finCalc:
    call calculate
    jmp outRes
    
nextSym:
    xor ah, ah    

loop inputLoop    
   
outRes:          
    mov ax, last_num 
    
    call outNum      
    
save_sp dw ?
save_ss dw ?

zzz segment
zzz ends
    
end start 