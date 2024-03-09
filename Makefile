# Makefile
# Copyright (C) 2024 John Jekel
# See the LICENSE file at the root of the project for licensing info.
#
# Makefile for the build-linux repository

GIT_EXECUTABLE := git

####################################################################################################
# Kernel Building
####################################################################################################

kernel/irve-mmu/arch/riscv/boot/Image kernel/irve-mmu/vmlinux &: kernel/irve-mmu/.config kernel/irve-mmu/.git initramfs/contents/bin/busybox $(shell find initramfs/contents -type f)
	@echo "\e[1mBuilding kernel/irve-mmu...\e[0m"
	$(MAKE) -C kernel/irve-mmu ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- all

kernel/irve-nommu/arch/riscv/boot/Image kernel/irve-nommu/vmlinux &: kernel/irve-nommu/.config kernel/irve-nommu/.git
	@echo "\e[1mBuilding kernel/irve-nommu...\e[0m"
	$(MAKE) -C kernel/irve-nommu ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- all

####################################################################################################
# Initramfs Setup and Busybox Building
####################################################################################################

initramfs/contents/bin/busybox: initramfs/busybox/busybox
	@echo "\e[1mCopying initramfs/busybox/busybox to initramfs/contents/bin/busybox...\e[0m"
	cp initramfs/busybox/busybox initramfs/contents/bin/busybox

initramfs/busybox/busybox: initramfs/busybox/.config initramfs/busybox/.git
	@echo "\e[1mBuilding initramfs/busybox...\e[0m"
	$(MAKE) -C initramfs/busybox ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- all

####################################################################################################
# Config Copying
####################################################################################################

kernel/irve-mmu/.config: kernel/config/irve-mmu-default
	@echo "\e[1mUsing kernel/config/irve-mmu-default as .config for kernel/irve-mmu...\e[0m"
	cp kernel/config/irve-mmu-default kernel/irve-mmu/.config

kernel/irve-nommu/.config: kernel/config/irve-nommu-default
	@echo "\e[1mUsing kernel/config/irve-nommu-default as .config for kernel/irve-nommu...\e[0m"
	cp kernel/config/irve-nommu-default kernel/irve-nommu/.config

initramfs/busybox/.config: initramfs/busybox-config-default
	@echo "\e[1mUsing initramfs/busybox-config-default as .config for initramfs/busybox...\e[0m"
	cp initramfs/busybox-config-default initramfs/busybox/.config

####################################################################################################
# Git Submodule Updating
####################################################################################################

kernel/irve-mmu/.git:
	@echo "\e[1mUpdating kernel/irve-mmu submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive kernel/irve-mmu

kernel/irve-nommu/.git:
	@echo "\e[1mUpdating kernel/irve-nommu submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive kernel/irve-nommu

initramfs/busybox/.git:
	@echo "\e[1mUpdating initramfs/busybox submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive kernel/irve-mmu

####################################################################################################
# Cleanup
####################################################################################################

.PHONY: clean
clean:
	@echo "\e[1mCleaning up...\e[0m"
	$(MAKE) -C kernel/irve-mmu ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- clean
	$(MAKE) -C kernel/irve-mmu ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- mrproper
	$(MAKE) -C kernel/irve-nommu ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- clean
	$(MAKE) -C kernel/irve-nommu ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- mrproper
	$(MAKE) -C initramfs/busybox ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- clean
	rm -f initramfs/busybox/.config
	rm -f initramfs/contents/bin/busybox
