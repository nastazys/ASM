cseg segment para public 'code'
    overlay proc
        assume cs:cseg, ds:dseg
        push ds
        
        add ax, bx
        
        pop ds
        retf
        overlay endp
    cseg ends
end