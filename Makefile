DIR = boot
OUT = build
TARGET = $(OUT)/boot.bin

SRC = $(DIR)/bootloader.asm $(DIR)/print.asm $(DIR)/disk_read.asm

all: $(TARGET) 

$(TARGET): $(SRC)
	mkdir -p $(OUT)
	nasm -f bin $< -o $@

clean:
	rm -rf $(TARGET)

boot: $(SRC)
	qemu-system-x86_64 -drive format=raw,file=$(TARGET)

.PHONY: all boot clean