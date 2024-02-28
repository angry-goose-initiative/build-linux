# CMakeLists.txt
# Copyright (C) 2024 John Jekel
# See the LICENSE file at the root of the project for licensing info.
#
# CMake configuration file for building the linux kernel
#

add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/vmlinux
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/arch/riscv/boot/Image
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu
    DEPENDS#FIXME how to detect all source code changes?
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/.git
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/.config
    COMMAND make ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- all -j 4
)
add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/.git
    WORKING_DIRECTORY
        ${PROJECT_SOURCE_DIR}
    COMMAND
        ${GIT_EXECUTABLE} submodule update --init --depth 1 --recursive kernel/irve-nommu
)
add_custom_command(#TODO make this configurable
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/.config
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/config/irve-nommu-default
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/.git
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/config/irve-nommu-default ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/.config
)
add_custom_target(irve-nommu-kernel ALL DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/vmlinux
    ${CMAKE_CURRENT_SOURCE_DIR}/irve-nommu/arch/riscv/boot/Image
)

add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/vmlinux
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/arch/riscv/boot/Image
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu
    DEPENDS#FIXME how to detect all source code changes?
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/.git
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/.config
    COMMAND make ARCH=riscv CROSS_COMPILE=riscv32-unknown-linux-gnu- all -j 4
)
add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/.git
    WORKING_DIRECTORY
        ${PROJECT_SOURCE_DIR}
    COMMAND
        ${GIT_EXECUTABLE} submodule update --init --depth 1 --recursive kernel/irve-mmu
)
add_custom_command(#TODO make this configurable
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/.config
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/config/irve-mmu-default
        ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/.git
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/config/irve-mmu-default ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/.config
)
add_custom_target(irve-mmu-kernel ALL DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/vmlinux
    ${CMAKE_CURRENT_SOURCE_DIR}/irve-mmu/arch/riscv/boot/Image
)
