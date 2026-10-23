OBJECTS = loader.o kmain.o io.o fb.o gdt.o gdt_s.o idt.o idt_s.o keyboard.o string.o am8.o utils.o mov.o
CC = gcc
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
         -nostartfiles -nodefaultlibs -fno-pic -fno-pie -Wall -Wextra -Werror -I ./include -c
LDFLAGS = -T link.ld -melf_i386 -no-pie
AS = nasm
ASFLAGS = -f elf

all: kernel.elf test.bin

kernel.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel.elf

hydra.img: kernel.elf
	qemu-img create -f raw hydra.img 5G
	sudo losetup -Pf hydra.img
	LOOP=$$(sudo losetup --show -Pf hydra.img) ; \
	sudo parted --script $$LOOP mktable msdos ; \
	sudo parted --script $$LOOP mkpart primary fat32 1% 100% ; \
	sudo parted --script $$LOOP set 1 boot on ; \
	sudo mkfs.vfat -F32 $$LOOP"p1" ; \
	sudo mkdir -p /mnt/hydra ; \
	sudo mount $$LOOP"p1" /mnt/hydra ; \
	sudo grub-install --target=i386-pc --boot-directory=/mnt/hydra/boot --force $$LOOP ; \
	sudo mkdir -p /mnt/hydra/modules ; \
	sudo cp ./test.bin /mnt/hydra/modules/test.bin ; \
	sudo cp ./kernel.elf /mnt/hydra/boot/kernel.elf ; \
	sudo cp ./grub.cfg /mnt/hydra/boot/grub/grub.cfg ; \
	sudo umount $$LOOP"p1" ; \
	sudo losetup -d $$LOOP ; \
	sync

run_qemu: hydra.img
	rm serial.out ; \
	touch serial.out ; \
	sudo qemu-system-i386 -M q35 -machine smm=on -vga std -d int,cpu_reset -drive file=./hydra.img,format=raw,cache=none -serial file:serial.out -m 4G #-audiodev driver=pipewire,id=snd0

run_bochs: hydra.img
	rm bochslog.txt ; \
	touch bochslog.txt ; \
	rm serial.out ; \
	touch serial.out ; \
	bochs -f bochsrc.txt -q

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

%.o: opcodes/%.c
	$(CC) $(CFLAGS) $< -o $@

%.bin: modules/%.s
	nasm -f bin $< -o $@

real_dev:
	@echo "device letter" ; \
	read letter ; \
	echo "part. number" ; \
	read num ; \
	sudo mkdir -p /mnt/hydra ; \
	sudo mount /dev/sd"$$letter$$num" /mnt/hydra ; \
	sudo mkdir -p /mnt/hydra/boot ; \
	sudo mkdir -p /mnt/hydra/boot/modules ; \
	sudo grub-install --target=i386-pc --boot-directory=/mnt/hydra/boot --force /dev/sd"$$letter" ; \
	make ; \
	sudo cp kernel.elf /mnt/hydra/boot/kernel.elf ; \
	sudo cp modules.tar /mnt/hydra/boot/modules/modules.tar ; \
	sudo cp grub.cfg /mnt/hydra/boot/grub/grub.cfg ; \
	sudo umount -l /dev/sd"$$letter$$num" ; \
	rm *.o kernel.elf *.bin

clean:
	rm -rf *.o kernel.elf test.bin am8.img
	sudo rm -rf /mnt/hydra
