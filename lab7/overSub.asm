cseg segment para public 'code'
    overlay proc
        assume cs:cseg
        push ds
        
        sub ax, cx
        
        pop ds
        retf
        overlay endp
    cseg ends
end