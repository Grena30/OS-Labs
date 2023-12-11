#!/bin/bash

binary_file="$1"
bootloader="$2"
init_bootloader="$3"

# Check if the binary file exists
nasm -f bin $binary_file -o main.bin
nasm -f bin $bootloader -o bootloader.bin
nasm -f bin $init_bootloader -o init_bootloader.bin

# Create an empty floppy disk image (1.44MB size)
floppy_image="floppy.img"
truncate -s 1474560 init_bootloader.bin
mv init_bootloader.bin $floppy_image

dd if="bootloader.bin" of="$floppy_image" bs=512 seek=1 conv=notrunc
dd if="main.bin" of="$floppy_image" bs=512 seek=3 conv=notrunc

echo "Binary file '$binary_file' successfully added to floppy image '$floppy_image'."
VM_NAME="BestOS"
VBoxManage controlvm "$VM_NAME" poweroff
echo "Virtual Machine $VM_NAME closed."

sleep 3

# Step 5: Change the storage to $flp_file in VirtualBox
VBoxManage storageattach "$VM_NAME" --storagectl "Floppy" --port 0 --device 0 --type fdd --medium "$floppy_image"
echo "Step 5: Storage in VirtualBox changed to $floppy_image."

# Step 6: Start the Virtual Machine
VBoxManage startvm "$VM_NAME"
echo "Step 6: Virtual Machine $VM_NAME started."

echo "All steps completed successfully."