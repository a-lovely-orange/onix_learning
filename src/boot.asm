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


; 0xb8000:文本显示器内存区域
mov ax, 0xb800
mov ds, ax
; 屏幕上第一个字符写成H
mov byte[0], 'H'

; 阻塞——跳转到当前行
jmp $

; 填充0
times 510 - ($ - $$) db 0

; 主引导扇区最后两个字节必须是0x55，0xaa
db 0x55, 0xaa