[org 0x7c00]

; 设置屏幕模式为文本模式，清除屏幕
mov ax, 3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

mov si, booting
call print

xchg bx, bx ; bochs魔数断点

mov edi, 0x1000 ; 读取的目标内存，从硬盘中读的数据要放在内存的0x1000处
mov ecx, 2      ; 起始扇区标号
mov bl, 4       ; 读取的扇区数量
call read_disk

cmp word [0x1000], 0x55aa
jnz error

jmp 0:0x1002
; 阻塞——跳转到当前行
jmp $


;;;;;;;;;; 读硬盘 ;;;;;;;;;;
read_disk:
    ; 设置读写扇区的数量：把bl里的数据写到端口地址0x1f2的寄存器中
    mov dx, 0x1f2   ; 读写扇区数量端口的地址
    mov al, bl
    out dx, al

    ; dx = 0x1f3：起始扇区低八位
    inc dx
    mov al, cl
    out dx, al

    ; dx = 0x1f4：起始扇区中八位
    inc dx
    shr ecx, 8
    mov al, cl
    out dx, al

    ; dx = 0x1f5：起始扇区高八位
    inc dx
    shr ecx, 8
    mov al, cl
    out dx, al

    ; dx = 0x1f6
    inc dx
    shr ecx, 8
    and ecx, 0b1111 ; 取出低四位
    mov al, 0b1110_0000  ; 主盘、LBA
    or al, cl
    out dx, al

    ; dx = 0x1f7,out
    inc dx
    mov al, 0x20    ; 读硬盘
    out dx, al

    xor ecx, ecx    ; ecx 清空
    mov cl, bl      ; 得到读写扇区数量
.read:
    push cx     ; 保存cx
    call .waits
    call .reads
    pop cx      ; 恢复cx
    loop .read      ; 循环次数：cl
    
    ret
    .waits
        ; 读0x1f7   
        mov dx, 0x1f7
        .check
            in al, dx
            ; 延迟一段时间
            jmp $+2 ; 相当于nop
            jmp $+2
            jmp $+2
            and al, 0b1000_1000 ; 留下第3位和第7位
            cmp al, 0b0000_1000 ; 数据是否准备好
            jnz .check          ; 如果数据没有准备完毕；那么继续check
        ret
    .reads
        ; 读0x1f0
        mov dx, 0x1f0
        mov cx, 256     ; 一个扇区有256个字=512字节
        .readw
            in ax, dx
            jmp $+2 ; 相当于nop
            jmp $+2
            jmp $+2
            mov [edi], ax
            add edi, 2
            loop .readw
        ret

;;;;;;;;;; 写硬盘 ;;;;;;;;;;
write_disk:
    ; 设置读写扇区的数量：把bl里的数据写到端口地址0x1f2的寄存器中
    mov dx, 0x1f2   ; 读写扇区数量端口的地址
    mov al, bl
    out dx, al

    ; dx = 0x1f3：起始扇区低八位
    inc dx
    mov al, cl
    out dx, al

    ; dx = 0x1f4：起始扇区中八位
    inc dx
    shr ecx, 8
    mov al, cl
    out dx, al

    ; dx = 0x1f5：起始扇区高八位
    inc dx
    shr ecx, 8
    mov al, cl
    out dx, al

    ; dx = 0x1f6
    inc dx
    shr ecx, 8
    and ecx, 0b1111 ; 取出低四位
    mov al, 0b1110_0000  ; 主盘、LBA
    or al, cl
    out dx, al

    ; dx = 0x1f7,out
    inc dx
    mov al, 0x30    ; 写硬盘
    out dx, al

    xor ecx, ecx    ; ecx 清空
    mov cl, bl      ; 得到读写扇区数量
.write:
    push cx     ; 保存cx
    call .writes
    call .waits
    pop cx      ; 恢复cx
    loop .write      ; 循环次数：cl
    
    ret

.waits
    ; 读0x1f7   
    mov dx, 0x1f7
    .check
        in al, dx
        ; 延迟一段时间
        jmp $+2 ; 相当于nop
        jmp $+2
        jmp $+2
        and al, 0b1000_1000 ; 留下第3位和第7位
        cmp al, 0b0000_0000 ; 数据是否准备好
        jnz .check          ; 如果数据没有准备完毕；那么继续check
    ret
.writes
    ; 读0x1f0
    mov dx, 0x1f0
    mov cx, 256     ; 一个扇区有256个字=512字节
    .writew
        mov ax, [edi]
        out dx, ax
        jmp $+2 ; 相当于nop
        jmp $+2
        jmp $+2
        add edi, 2
        loop .writew
    ret

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

booting:
    db "Booting Onix...", 10, 13, 0 ;\n\r

error:
    mov si, .msg
    call print
    hlt;
    jmp $
    .msg db "Booting Error!!!", 10, 13, 0

; 填充0
times 510 - ($ - $$) db 0

; 主引导扇区最后两个字节必须是0x55，0xaa
db 0x55, 0xaa
