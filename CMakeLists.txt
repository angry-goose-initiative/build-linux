# CMakeLists.txt
# Copyright (C) 2024 John Jekel
# See the LICENSE file at the root of the project for licensing info.
#
# CMake configuration file for build-linux
#

cmake_minimum_required(VERSION 3.16.3)
project(build-linux VERSION 0.0.1)

set(GIT_EXECUTABLE git)

#https://stackoverflow.com/questions/1435953/how-can-i-pass-git-sha1-to-compiler-as-definition-using-cmake
execute_process(
    COMMAND                             "${GIT_EXECUTABLE}" describe --match=NeVeRmAtCh --always --abbrev=40 --dirty
    WORKING_DIRECTORY                   "${PROJECT_SOURCE_DIR}"
    OUTPUT_VARIABLE                     BUILD_LINUX_GIT_CHECKSUM
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_subdirectory(kernel)
