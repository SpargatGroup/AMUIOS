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
    mkdir -p build/$build/system/obj/kernel
    for file in $kernel_files; do
        gcc -nostartfiles -nostdlib -O2 -Wall -Wextra -m$build -c $file -o build/$build/system/obj/kernel/$(basename ${file%.c}.o)
    done

    ## bootloader build
    cd bootloader
    sudo bash get.sh
    cd ../

    ## kernel
    if [ $build -eq 32 ]; then
        arhitecture_boot=elf_i386
    elif [ $build -eq 64 ]; then
        arhitecture_boot=elf_x86_64
    else
        echo "Invalid architecture: $build"
        exit 1
    fi
    ld -m $arhitecture_boot -T linker.ld -nostdlib --static -o build/$build/system/kernel.bin build/$build/system/obj/kernel/*.o

    ## move depencies
    mkdir -p build/$build/boot/limine
    cp limine.conf build/$build/boot/limine/limine.conf
    cp -r bootloader/limine build/$build/boot/

    ## build iso
    xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
        -apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        build/$build -o build/$build/openamui-$build.iso
done