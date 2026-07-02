ASM = nasm
QEMU = qemu-system-x86_64

BOOT = boot
BUILD = build
IMAGE = images

MBR_BIN = $(BUILD)/stage1_bootloader.bin
STAGE2_BIN = $(BUILD)/stage2_bootloader.bin
DISK_IMG = $(IMAGE)/boot.img

MBR_SRC = $(BOOT)/stage1_bootloader.asm
STAGE2_SRC = $(BOOT)/stage2_bootloader.asm

STAGE2_DEPS = $(BOOT)/print16.asm \
			  $(BOOT)/gdt.asm \
			  $(BOOT)/switch_to_pm.asm

TARGET = $(DISK_IMG)

all: $(TARGET) 

$(BUILD) $(IMAGE):
	@mkdir -p $@

$(MBR_BIN): $(MBR_SRC) | $(BUILD)
	$(ASM) -f bin $< -o $@

$(STAGE2_BIN): $(STAGE2_SRC) $(STAGE2_DEPS) | $(BUILD)
	$(ASM) -f bin $< -o $@ -I $(BOOT)

$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) | $(IMAGE)
	@cat $(MBR_BIN) $(STAGE2_BIN) > $@

run: $(DISK_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),if=floppy -boot a

clean:
	rm -rf $(BUILD) $(IMAGE)

.PHONY: all run clean