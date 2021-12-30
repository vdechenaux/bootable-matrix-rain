.PHONY: qemu

matrix.bin: matrix.asm
	nasm -f bin matrix.asm -o matrix.bin

qemu: matrix.bin
	qemu-system-x86_64 -drive format=raw,file=matrix.bin
