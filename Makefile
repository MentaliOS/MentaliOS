KERNEL_SRC := $(wildcard kernel/.)

all: $(KERNEL_SRC)
$(KERNEL_SRC):
	$(MAKE) run -C $@
	cp kernel/build/*.iso .

run:
	qemu-system-x86_64 -cdrom MentaliOS-x86_64.iso -m 32M

.PHONY: all $(KERNEL_SRC) run
