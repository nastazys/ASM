.model tiny  
.code 
    org 100h
    
    mov ax,@data
    mov ds,ax
              
    lea dx,base_msg
    call out_str
    lea dx,base_str
    call in_str
            
    lea dx,srch_msg  
    call out_str
    lea dx,srch_str
    call in_str
    
    lea dx,ins_msg
    call out_str
    lea dx,ins_str
    call in_str
                        
    xor ax, ax
    xor dx, dx 
                       
    mov al, base_str[1]         ;string length 
    cmp ax, 0
    je error1 
    
    mov dl, ins_str[1] 
    cmp dx, 0
    je error1 
    
    xor dx, dx  
    mov dl, srch_str[1]
    cmp dx, 0
    je error1                                                              
  
    
    mov si, offset base_str + 2
    mov di, offset srch_str + 2
    
    sub al, dl    
      
    xor cx, cx
    mov cl, al
    inc cx 
    
search:   
    pusha
    xor cx, cx
    mov cx, dx
    repe cmpsb         ;cmpsb: cx - num symbols to compare, si, di - pointers to compareable strings
    jz found 
    popa 
    inc si             
loop search
    
    mov ah,9
    lea dx, notfound_msg  ;not found
    int 21h 
    int 20h
         
        found: 
        
        mov cx, si
        sub cx, offset base_str + 2    ;num of symbols before found word + length of found word
        
        xor ax, ax
        mov al, srch_str[1]
        ;;mov di, offset res_str + 1  
        mov si, offset ins_str + 2
        sub cx, ax          ;position to insert, num of symbols before found word    
        cmp cx, 0
        jz first_word
        push cx
        
        mov di, offset res_str + 1      ;copy_str: di -  where to copy, si - copy base, cx - num of symbols to copy
        mov si, offset base_str + 2     ; base_str = BBBBB BBB FFFF RRRRR
                                        ; ins_str = IIII
        call copy_str;res_str = BBBB_BBB_
        
        push si              ;pointer to the rest of base_str
        
        ;first_word:
        
        xor cx, cx
        mov cl, ins_str[1]
        mov si, offset ins_str + 2
        
        call copy_str;res_str = BBBB_BBB_IIII  
        
        xor cx, cx           ;separate insert word by space
        mov cl, 1
        mov si, ' '
        call copy_str;res_str = BBBB_BBB_IIII_
        
        pop si      
        pop cx
        inc cx                       ;+offset 
        inc cx
        call copy_str;res_str = BBBB_BBB_IIII_FFFF_RRRRR
        
jmp res_in
        
        first_word:   
        xor cx, cx
        mov cl, ins_str[1]
        mov di, offset res_str + 1      
        mov si, offset ins_str + 2  
        call copy_str     
        ;push cx
        xor cx, cx           ;separate insert word by space
        mov cl, 1
        mov si, ' '
        call copy_str;      
        ;pop cx
        ;inc cx  
        mov cl, base_str[1]   
        mov si, offset base_str + 2 
        call copy_str      
  res_in:      
        lea dx, res_msg   
        call out_str
        lea dx, res_str+1
        call out_str
        
        int 20h
   error1:
        lea dx, er1_msg   
        call out_str
        
        ret 
;;;;;;;;;;PROCEDURES      
; out_str and in_str need str in dx
out_str proc  
    pusha  
    
    mov DL, 0Dh
    mov Ah, 02h
    int 21h 
    
    mov DL, 0Ah
    mov Ah, 02h
    int 21h          
    
    popa
    mov ah,9
    int 21h
    
    ret    
out_str endp    

in_str proc         
    push ax
    mov ah,0ah
    int 21h   
    pop ax
    
    ret 
in_str endp            

;si - pointer to the start of base string
;di - pointer to the start of insert string 
copy_str proc  
    push ax  
      
    cmp cx, 0
    jz end_copy   
    
    loop_str:  
        mov ax, [si]
        mov [di], ax 
        inc si
        inc di
    loop loop_str
   
    end_copy:        
    pop ax  
    ret
    copy_str endp
.data 
     notfound_msg db "There is no such word in your string! $"
     base_msg db "Enter base string: $"  
     srch_msg db "Enter the word to find in the base string: $"   
     ins_msg db "Enter the word to insert in the base string after found word: $" 
     res_msg db "The result string is: $"  
     er1_msg db "Input error! $"
     base_str db 202,202 dup ('$')     
     srch_str db 202,202 dup ('$')               
     ins_str db 202,202 dup ('$') 
     res_str db 202,202 dup ('$')             
 
                                        