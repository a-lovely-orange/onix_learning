[org 0x1000]

dw 0x55aa ; 魔数，用于判断错误，如果从硬盘读入的内核加载器开头不是0x55aa，则说明读入错误

; 打印字符串
mov si, loading
call print

xchg bx, bx ; bochs魔数断点

; 检测内存
detect_memory:
    xor ebx, ebx    ; 将ebx置0

    ; 缓冲区段地址
    mov ax, 0
    mov es, ax

    ; es:di: 结构体的缓冲区位置
    mov edi, ards_buffer
    mov edx, 0x534d4150 ;固定签名：SMAP的ASICC码

.next:
    ; 子功能号
    mov eax, 0xe820
    ; ards结构的大小（字节）
    mov ecx, 20
    ; 调用0x15系统调用（软中断）
    int 0x15

    ; 如果CF置位(CF = 1)，表示出错
    jc error

    ; 将缓存指针指向下一个结构体
    add di, cx

    ; 将结构体数量加一，word表示将ards_count作为word(2 bytes)来看待
    inc word[ards_count]

    ; 判断检测是否结束，!=0：检测未结束；=0：检测结束
    cmp ebx, 0
    jnz .next

    ; 打印结束
    mov si, detecting
    call  print

    xchg bx, bx ; bochs魔数断点

    ; cx：结构体数量，loop循环次数
    mov cx, [ards_count]
    ; si：结构体字段指针(0, 4, 8, 12, 16)
    mov si, 0
.show
    mov eax, [ards_buffer + si]
    mov ebx, [ards_buffer + si + 8]
    mov edx, [ards_buffer + si + 16]
    loop .show
    add si, 20
    xchg bx, bx

; 阻塞
jmp $


; print函数实现
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

; 变量生命
loading:    ; loading时出现的字符串
    db "Loading Onix...", 10, 13, 0 ;\n\r
detecting:    ; memory detecting时出现的字符串
    db "Detecting Memory Success!!!", 10, 13, 0 ;\n\r

; 错误处理
error:
    mov si, .msg
    call print
    hlt;
    jmp $
    .msg db "Loading Error!!!", 10, 13, 0

ards_count:
    dw 0
ards_buffer: