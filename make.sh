#!/bin/bash

rm -rf build
mkdir -p build

for file in kernel/*.c kernel/*.cpp; do
    mkdir -p build/obj
    gcc -nostartfiles -nostdlib -O2 -Wall -Wextra -c $file -o build/obj/$(basename ${file%.cpp}.o)
done

mkdir -p build/boot
ld -T linker.ld -nostdlib --static -o build/boot/kernel.bin build/obj/*.o

mkdir -p build/iso
grub-mkrescue -o build/iso/amui.iso build