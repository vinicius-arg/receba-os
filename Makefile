# Assembly compilator and emulator
ASM = nasm
QEMU = qemu-system-x86_64

# Main directories
SRC  = src
SCD  = shellcodes
BIN  = bin

# Project directories
BOOT 	= $(SRC)/boot
BUILD 	= $(SRC)/build
IMAGE 	= $(SRC)/images
UTILS 	= $(SRC)/utils
BOOTKIT = $(SRC)/bootkit

# FreeDOS and Bootloader image paths
SYSTEM_ZIP = $(IMAGE)/freedos_hd.zip
SYSTEM_IMG = $(IMAGE)/freedos_hd.img
DISK_IMG   = $(IMAGE)/boot.img

# Bootloader binaries
MBR_BIN 	= $(BUILD)/stage1_bootloader.bin
STAGE2_BIN 	= $(BUILD)/stage2_bootloader.bin

# Stage 1 sources and dependencies
MBR_SRC = $(BOOT)/stage1_bootloader.asm
MBR_DEPS = $(UTILS)/disk_read.asm \
		   $(UTILS)/print16.asm

# Stage 2 sources and dependencies
STAGE2_SRC = $(BOOT)/stage2_bootloader.asm
STAGE2_DEPS = $(BOOT)/gdt.asm \
			  $(BOOT)/protected_mode.asm \
			  $(BOOTKIT)/ivt_hook.asm

TARGET = $(DISK_IMG)

all: $(TARGET) 

# Creates build and image dirs
$(BUILD) $(IMAGE) $(BIN):
	@mkdir -p $@
	@mkdir $(BIN)

# Handles FreeDOS image provisioning
$(SYSTEM_IMG): $(SYSTEM_ZIP)
	@unzip -o $(SYSTEM_ZIP) -d $(IMAGE)/
	@touch $@

# Compiles bootloader/bootkit
$(MBR_BIN): $(MBR_SRC) $(MBR_DEPS) | $(BUILD)
	$(ASM) -f bin $< -o $@ -I $(BOOT)/

$(STAGE2_BIN): $(STAGE2_SRC) $(STAGE2_DEPS) | $(BUILD)
	$(ASM) -f bin $< -o $@ -I $(BOOT)/ -I$(BOOTKIT)/

# Provides a unified binary
$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) | $(IMAGE)
	@cat $(MBR_BIN) $(STAGE2_BIN) > $@

# Runs emulation
run: $(DISK_IMG) $(SYSTEM_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),if=floppy \
			-drive format=raw,file=$(SYSTEM_IMG),if=ide,index=0 \
			-serial tcp:127.0.0.1:3000,server,nowait \
			-boot a

clean:
	rm -rf $(BUILD) $(DISK_IMG)

.PHONY: all run clean