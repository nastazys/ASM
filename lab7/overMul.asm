cseg segment para public 'code'
    overlay proc
        assume cs:cseg
        push ds
        
        mul cx
        
        pop ds
        retf
        overlay endp
    cseg ends
end