#!/bin/bash

rm -rf build

# vals
kernel_files=$(find kernel -type f \( -name "*.c" -o -name "*.cpp" \))
bootloader_files=$(find bootloader -type f \( -name "*.c" -o -name "*.cpp" \))
arhitecture=(32 64)

# build
for build in "${arhitecture[@]}"; do
    ## kernel build
    mkdir -p build/$build
    mkdir -p build/$build/obj/kernel
    for file in $kernel_files; do
        gcc -nostartfiles -nostdlib -O2 -Wall -Wextra -m$build -c $file -o build/$build/obj/kernel/$(basename ${file%.c}.o)
    done

    ## bootloader build
    mkdir -p build/$build/obj/bootloader
    for file in $bootloader_files; do
        gcc -nostartfiles -nostdlib -O2 -Wall -Wextra -m$build -c $file -o build/$build/obj/bootloader/$(basename ${file%.c}.o)
    done

    ## bootloader
    mkdir -p build/$build/boot
    if [ $build -eq 32 ]; then
        arhitecture_boot=elf_i386
    elif [ $build -eq 64 ]; then
        arhitecture_boot=elf_x86_64
    else
        echo "Invalid architecture: $build"
        exit 1
    fi
    ld -m $arhitecture_boot -T linker.ld -nostdlib --static -o build/$build/boot/kernel.bin build/$build/obj/bootloader/*.o

    ## iso build
    grub-mkrescue -o build/$build/openamui-$build.iso build/$build # don't add a supplimentary empty folder to the build of iso
done