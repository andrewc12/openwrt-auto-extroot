#!/bin/bash
dd if=/dev/zero bs=1M count=6000 > ~/usb.img
export card=$(losetup -f --show -P ~/usb.img)

    # erase partition table
dd if=/dev/zero of=${card} bs=1M count=1

    # sda1 is 'swap'
    # sda2 is 'root'
    # sda3 is 'data'
    fdisk ${card} <<EOF
o
n
p
1

+64M
n
p
2

+512M
n
p
3


t
1
82
w
q
EOF

export rootUUID=05d615b3-bef8-460c-9a23-52db8d09e000
export dataUUID=05d615b3-bef8-460c-9a23-52db8d09e001
export swapUUID=05d615b3-bef8-460c-9a23-52db8d09e002


    mkswap -L swap -U $swapUUID ${card}p1
    mkfs.ext4 -L root -U $rootUUID ${card}p2
    mkfs.ext4 -L data -U $dataUUID ${card}p3

 losetup -d /dev/loop0
 sync
gzip ~/usb.img
