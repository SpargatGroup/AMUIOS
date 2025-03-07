#!/bin/bash

rm -rf build
mkdir -p build

# vals
kernel_files=$(find kernel -type f \( -name "*.c" -o -name "*.cpp" \))
bootloader_files=$(find bootloader -type f \( -name "*.c" -o -name "*.cpp" \))

mkdir -p build/obj/kernel
for file in $kernel_files; do
    gcc -nostartfiles -nostdlib -O2 -Wall -Wextra -c $file -o build/obj/kernel/$(basename ${file%.c}.o)
done

mkdir -p build/obj/bootloader
for file in $bootloader_files; do
    gcc -nostartfiles -nostdlib -O2 -Wall -Wextra -c $file -o build/obj/bootloader/$(basename ${file%.c}.o)
done

mkdir -p build/boot
ld -T linker.ld -nostdlib --static -o build/boot/kernel.bin build/obj/bootloader/*.o

grub-mkrescue -o build/amui.iso build # don't add a supplimentary empty folder to the build of iso