[org 0x1000]

dw 0x55aa ; 魔数，用于判断错误，如果从硬盘读入的内核加载器开头不是0x55aa，则说明读入错误

xchg bx, bx ; bochs魔数断点

; 打印字符串
mov si, loading
call print

jmp $

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

loading:
    db "Loading Onix...", 10, 13, 0 ;\n\r

error:
    mov si, .msg
    call print
    hlt;
    jmp $
    .msg db "Loading Error!!!", 10, 13, 0