ASM = nasm
QEMU = qemu-system-x86_64

BOOT = boot
BUILD = build
IMAGE = images
UTILS = utils
BOOTKIT = bootkit

SYSTEM_ZIP = $(IMAGE)/freedos_hd.zip
SYSTEM_IMG = $(IMAGE)/freedos_hd.img

MBR_BIN = $(BUILD)/stage1_bootloader.bin
STAGE2_BIN = $(BUILD)/stage2_bootloader.bin
DISK_IMG = $(IMAGE)/boot.img

MBR_SRC = $(BOOT)/stage1_bootloader.asm

MBR_DEPS = $(UTILS)/disk_read.asm \
		   $(UTILS)/print16.asm

STAGE2_SRC = $(BOOT)/stage2_bootloader.asm

STAGE2_DEPS = $(BOOT)/gdt.asm \
			  $(BOOT)/protected_mode.asm \
			  $(BOOTKIT)/ivt_hook.asm

TARGET = $(DISK_IMG)

all: $(TARGET) 

$(BUILD) $(IMAGE):
	@mkdir -p $@

$(SYSTEM_IMG): $(SYSTEM_ZIP)
	@unzip -o $(SYSTEM_ZIP) -d $(IMAGE)/
	@touch $@

$(MBR_BIN): $(MBR_SRC) $(MBR_DEPS) | $(BUILD)
	$(ASM) -f bin $< -o $@ -I $(BOOT)/

$(STAGE2_BIN): $(STAGE2_SRC) $(STAGE2_DEPS) | $(BUILD)
	$(ASM) -f bin $< -o $@ -I $(BOOT)/

$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) | $(IMAGE)
	@cat $(MBR_BIN) $(STAGE2_BIN) > $@

run: $(DISK_IMG) $(SYSTEM_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),if=floppy \
			-drive format=raw,file=$(SYSTEM_IMG),if=ide,index=0 \
			-boot a

clean:
	rm -rf $(BUILD) $(DISK_IMG)

.PHONY: all run clean