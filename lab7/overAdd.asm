cseg segment para public 'code'
    overlay proc
        assume cs:cseg
        ;push ds
        
        add ax, cx
        
        ;pop ds
        retf
        overlay endp
    cseg ends
end