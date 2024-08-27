linux挂载ntfs读写分区

查找NTFS分区

使用 `lsblk` 或 `df -hT` 命令来查看已挂载的分区信息。

如`/dev/nvme0n1p5` 挂载在 `/media/sky/F66CB8CF6CB88BBD` 目录下

确定UUID或标签

```
sudo blkid
```

添加分区挂载/etc/fstab

在文件末尾添加一行，指定分区的挂载点和挂载选型

```
UUID=F66CB8CF6CB88BBD  /media/sky/F66CB8CF6CB88BBD  ntfs  rw,relatime,errors=remount-ro  0  0
```

或

```

UUID=F66CB8CF6CB88BBD  /media/sky/F66CB8CF6CB88BBD  ntfs-3g  rw,relatime,errors=remount-ro  0  0
```

前提是已安装ntfs-3g

```
sudo apt update
sudo apt install ntfs-3g
```



卸载已挂载的分区：

```
sudo umount /dev/nvme0n1p5

```

如果卸载命令提示分区被使用中，你可以使用 `fuser` 命令来找出哪个进程正在使用该分区：

```
sudo fuser -vm /media/sky/F66CB8CF6CB88BBD
```

这将列出所有使用该目录的进程。你可以终止这些进程，或者使用 `-k` 选项强制卸载：

```shell
sudo umount /media/sky/F66CB8CF6CB88BBD
```



手动挂载分区：

```
sudo mount -t ntfs-3g -o rw,relatime,errors=remount-ro /dev/nvme0n1p5 /media/sky/F66CB8CF6CB88BBD
```

如挂载失败可检查并修复ntfs分区：

```
sudo ntfsfix /dev/nvme0n1p5
```

重新挂载所有分区：

```
sudo mount -a
```

检查挂载状态：

```
mount | grep /media/sky/F66CB8CF6CB88BBD
```



