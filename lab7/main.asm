.model	small
.stack	100h  

.data

epb dw ?
dw 0     
run_adr dw 0
run_seg dw ?
path db "OVERADD.exe", 0                         

.code    
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
 
mov bx, offset EPB 
mov dx, offset path 
mov ax, 4B03h 
int 21h       
 
push ds
push es
mov cs:save_ss, ss
mov cs:save_sp, sp

call dword ptr run_adr  

mov sp, cs:save_sp
mov ss, cs:save_ss
pop es
pop ds       
 
save_sp dw ?
save_ss dw ?

zzz segment
zzz ends

end start