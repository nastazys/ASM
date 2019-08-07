cseg segment para public 'code'
    overlay proc
        assume cs:cseg
        push ds
        
        xor dx, dx
        div cx
        
        pop ds
        retf
        overlay endp
    cseg ends
end