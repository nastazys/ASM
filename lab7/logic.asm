.model	small
.stack	100h  

.data
start_msg      db  0Dh,'Enter string A1 X A2 X A3 (max length - 100): $' 
error_msg      db  0Dh,'Bad input, enter again! $'             
endl_msg                    db  0Ah, 0Dh, '$'
base_str db 202,202 dup ('$')          
buffer                      dw  ?    
last_num                    dw  ?  
last_oper                   db  ?

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

inStr proc         
    push ax
    mov ah,0ah
    int 21h   
    pop ax
    
    ret 
inStr endp   

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
        add ax, buffer
        jmp endCalc     
        
    minus:
        sub ax, buffer
        jmp endCalc    
        
    multipl:
        mul buffer
        jmp endCalc 
        
    diver: 
        xor dx, dx
        div buffer  
        
    endCalc:  
        mov last_num, ax 
        mov last_oper, bh   
        mov buffer, 0
    
    exitCalc:     
    ret
calculate endp

;al - num     
outNum proc
    mov cl, 10
    outLoop:
    div cl
    mov dl, ah
    
    cmp dl, 0
    jne do  
    
    cmp al, 0
    jne do
    
    jmp exit
    
    do:   
    push ax
    
    add dl, '0' 
    mov ah, 02h
    int 21h      
    
    pop ax
    xor ah, ah
    
    jmp outLoop
    exit: 
    ret
outNum endp

start:

mov	ax,@data                      
mov	ds,ax 
           
beg:           
lea dx, start_msg
call showMsg  

lea dx, base_str
call inStr

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
    
end start  

