mkfs.ext4 -L nixos /dev/sda3
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda1
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
