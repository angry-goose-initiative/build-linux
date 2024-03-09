# Makefile
# Copyright (C) 2024 John Jekel
# See the LICENSE file at the root of the project for licensing info.
#
# Makefile for the build-linux repository

GIT_EXECUTABLE := git

####################################################################################################
# Kernel Building
####################################################################################################

kernel/irve-mmu/arch/riscv/boot/Image kernel/irve-mmu/vmlinux &: kernel/irve-mmu/.config kernel/irve-mmu/.git initramfs/contents/bin/busybox initramfs/contents/inception/irve $(shell find initramfs/contents -type f)
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

initramfs/contents/inception/irve: initramfs/irve-inception/build/src/irve
	@echo "\e[1mCopying initramfs/irve-inception/build/src/irve to initramfs/contents/inception/irve...\e[0m"
	cp initramfs/irve-inception/build/src/irve initramfs/contents/inception/irve
	#I'm too lazy to make each of the test programs an individual target
	@echo "\e[1mCopying test programs...\e[0m"
	cp initramfs/irve-inception/build/rvsw/rvsw/src/single_file/c/*.elf initramfs/contents/inception/rvsw
	cp initramfs/irve-inception/build/rvsw/rvsw/src/single_file/cxx/*.elf initramfs/contents/inception/rvsw
	#Remove this test program since it is pretty large (5MB)
	rm -f initramfs/contents/inception/rvsw/morevm_smode.elf


initramfs/irve-inception/build/src/irve: initramfs/irve-inception/.git
	@echo "\e[1mBuilding initramfs/irve-inception...\e[0m"
	cd initramfs/irve-inception && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DIRVE_INCEPTION=1 ..
	$(MAKE) -C initramfs/irve-inception/build

####################################################################################################
# Config Copying
####################################################################################################

kernel/irve-mmu/.config: kernel/config/irve-mmu-default kernel/irve-mmu/.git
	@echo "\e[1mUsing kernel/config/irve-mmu-default as .config for kernel/irve-mmu...\e[0m"
	cp kernel/config/irve-mmu-default kernel/irve-mmu/.config

kernel/irve-nommu/.config: kernel/config/irve-nommu-default kernel/irve-nommu/.git
	@echo "\e[1mUsing kernel/config/irve-nommu-default as .config for kernel/irve-nommu...\e[0m"
	cp kernel/config/irve-nommu-default kernel/irve-nommu/.config

initramfs/busybox/.config: initramfs/busybox-config-default initramfs/busybox/.git
	@echo "\e[1mUsing initramfs/busybox-config-default as .config for initramfs/busybox...\e[0m"
	cp initramfs/busybox-config-default initramfs/busybox/.config

####################################################################################################
# Git Submodule Updating
####################################################################################################

# Make the clones not happen at the same time by making them depend on each other, since
# git locks the .git directory so things will fail if they happen at the same time

kernel/irve-mmu/.git: initramfs/busybox/.git initramfs/irve-inception/.git
	@echo "\e[1mUpdating kernel/irve-mmu submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive kernel/irve-mmu

kernel/irve-nommu/.git:
	@echo "\e[1mUpdating kernel/irve-nommu submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive kernel/irve-nommu

initramfs/busybox/.git: initramfs/irve-inception/.git
	@echo "\e[1mUpdating initramfs/busybox submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive initramfs/busybox

initramfs/irve-inception/.git:
	@echo "\e[1mUpdating initramfs/irve-inception submodule...\e[0m"
	$(GIT_EXECUTABLE) submodule update --init --depth 1 --recursive initramfs/irve-inception

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
	rm -rf initramfs/irve-inception/build
