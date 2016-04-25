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

    mkswap -L swap ${card}p1
    mkfs.ext4 -L root ${card}p2
    mkfs.ext4 -L data ${card}p3

export rootUUID=$(blkid -s UUID -o value ${card}p2)
export dataUUID=$(blkid -s UUID -o value ${card}p3)
export swapUUID=$(blkid -s UUID -o value ${card}p1)

cp fstab image-extras/common/etc/config/fstab

sed -i "s/##SWAPUUID##/$swapUUID/g" image-extras/common/etc/config/fstab
sed -i "s/##ROOTUUID##/$rootUUID/g" image-extras/common/etc/config/fstab
sed -i "s/##DATAUUID##/$dataUUID/g" image-extras/common/etc/config/fstab

 losetup -d /dev/loop0
 sync
gzip ~/usb.img
