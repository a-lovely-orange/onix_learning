参考博客如下：
1. https://blog.csdn.net/OceanWaves1993/article/details/130467985
2. https://blog.csdn.net/earth1994/article/details/139706014


# 更新VMware16到VMware17

更新原因：archlinux下载的版本是2024.05.01，基于Linux6.0内核，但是VMware16没有Linux6.x内核选项，故更新，
但是更新以后还是没有6.x的选项，这里先**埋一个坑**。

>问题解决：由于VMware被broad收购了，所以去broad官网下载的VMware才有Linux6.x内核。

# 配置ssh协议——cmd远程连接



# 创建ArchLinux虚拟机

## 设置虚拟机密码
- `passwd`（输入密码、确认密码）

## 创建磁盘分区

- 查看磁盘分区：`lsblk`
- 创建磁盘分区：`fdisk /dev/sda`
  - n：新建分区
  - d：删除分区
  - w：保存修改

>分区设置：

>sda1:挂载根目录:3G

>sda2:挂载swap目录（虚拟内存，大小与内存一致即可）:2G

>sda3:500M(留给可能的boot)

>sda4:挂载home目录:2.5G

## 格式化分区
- `mkfs.ext4 /dev/sda1`
- `mkswap /dev/sda4`

## 挂载分区
- `mount /dev/sda1 /mnt`
- `swapon /dev/sda4`

## 更新镜像
- 'pacman -Sy'
- 选zju镜像

## 安装系统
`pacstrap -i /mnt base base-devel linux linux-firmware`

# 配置系统

## 生成文件系统表
- `genfstab -U -p /mnt > /mnt/etc/fstab`

## 进入新系统
- `arch-chroot /mnt`

## 配置文字编码
- `vim /etc/locale.gen`

将 zh_CN 开头的行全部取消注释，再找到 en_US.UTF-8 UTF-8也取消注释。 编辑完成之后保存。

- `locale-gen`
- `echo LANG=en_US.UTF-8 > /etc/locale.conf`
- `rm -f /etc/localtime`：删除原来的UTC时区
- `ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime`：设置系统时区为上海
- `hwclock --systohc --localtime`：设置硬件时间为本地时间
- `echo orange > /etc/hostname`：设置用户名
- `passwd`：设置root用户密码
- `pacman -S ntfs-3g`：安装 ntfs 文件系统，以便访问 Windows 磁盘

## 配置网络

- `pacman -S iw wpa_supplicant wireless_tools net-tools`：安装网络工具
- `pacman -S dialog`：安装终端工具
- `pacman -S networkmanager`：安装networkmanager，这样就能自动配置网络
- `systemctl enable NetworkManager`：设置为开机启动
- `pacman -S openssh`：安装ssh
- `systemctl enable sshd`：设置为开机启动

## 配置引导
- `pacman -S grub`：安装引导程序
- `grub-install --target=i386-pc /dev/sda`：安装BIOS引导
- `grub-mkconfig -o /boot/grub/grub.cfg`：生成配置文件
- `pacman -S iw wpa_supplicant wireless_tools net-tools`：安装网络工具
- `pacman -S dialog`：安装终端对话框
- `pacman -S networkmanager`：安装networkmanager
  - `systemctl enable NetworkManager`：并设置为自启动
- `pacman -S openssh`：安装openssh
  - `systemctl enable NetworkManager`：并设置为自启动
- `useradd -G root -m orange`：添加用户
  - `passwd orange`：给orange设置密码
