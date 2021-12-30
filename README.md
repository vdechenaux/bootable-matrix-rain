# Bootable matrix rain

## Emulator
If you have `qemu-system-x86_64`, simply run `make qemu`.

It also works with VMware. You will probably have to rename the `matrix.bin` to `matrix.img` to select the file (as a floppy disk image).

## Real hardware
This *bootloader* has been tested on real hardware, it should works on yours !

Just compile (`make`) the code and use `dd` with `matrix.bin` as input to create a bootable usb device.

```
make
dd if=matrix.bin of=/dev/<yourUsbDevice> bs=512 count=1
```

## Demo

![Video of the project](qemu.gif?raw=true)
