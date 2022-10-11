# Copyright (C) TetroLabs Inc.
# All rights reserved

CC = gcc

VERSION = v0.1.0
ARCH = x86_64

WARNINGS = -Wall -W -Wstrict-prototypes -Wmissing-prototypes -Wsystem-headers
CFLAGS = -g -msoft-float -O -fno-stack-protector
CPPFLAGS = -nostdinc -I. -Ilib -Ilib/kernel 
ASFLAGS = -Wa,--gstabs
LDFLAGS = -T link.ld -melf_i386
DEPS = -MMD -MF $(@:.o=.d)

all: kernel.elf os run

# Kernel code
kernel_SRC  = start.S
kernel_SRC += kmain.c

# Devices code.
devices_SRC = devices/vga.c

# Lib code.
lib_SRC  = lib/stdio.c
lib_SRC += lib/string.c
lib_SRC += lib/arithmetic.c
lib_SRC += lib/kernel/console.c

SUBDIRS = kernel devices lib
SOURCES = $(foreach dir,$(SUBDIRS),$($(dir)_SRC))
OBJECTS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(SOURCES)))
DEPENDS = $(patsubst %.o,%.d,$(OBJECTS))

OUT_ISO = MentaliOS-$(VERSION)-$(ARCH).iso

%.o: %.c
	$(CC) -m32 -c $< -o $@ $(CFLAGS) $(CPPFLAGS) $(WARNINGS) $(DEFINES) $(DEPS)

%.o: %.S
	$(CC) -m32 -c $< -o $@ $(ASFLAGS) $(CPPFLAGS) $(DEFINES) $(DEPS)

kernel.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel.elf
kernel-dev.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel-dev.elf
kernel-shell.elf: $(OBJECTS)
	ld $(LDFLAGS) $(OBJECTS) -o kernel-shell.elf

os: kernel.elf kernel-dev.elf kernel-shell.elf
	mkdir -p iso/boot/grub
	cp kernel.elf iso/boot/kernel.elf
	cp kernel-dev.elf iso/boot/kernel-dev.elf
	cp kernel-dev.elf iso/boot/kernel-shell.elf
	cp stage2_eltorito iso/boot/grub/
	cp *.lst iso/boot/grub
	cp win.gz iso/boot/grub
	genisoimage -R                              \
				-b boot/grub/stage2_eltorito    \
				-no-emul-boot                   \
				-boot-load-size 4               \
				-A os                           \
				-input-charset utf8             \
				-quiet                          \
				-boot-info-table                \
				-o $(OUT_ISO)                      \
				iso

run: os
	qemu-system-x86_64 -cdrom $(OUT_ISO)

clean:
	rm -f $(OBJECTS) $(DEPENDS) 
	rm *.elf
	rm -rf iso
	rm $(OUT_ISO)
