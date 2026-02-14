# Nintendo Switch Toolchain File for CMake
# This toolchain file configures CMake to cross-compile for Nintendo Switch

# Check for Nintendo SDK
if(NOT DEFINED ENV{NINTENDO_SDK_ROOT})
    message(FATAL_ERROR "NINTENDO_SDK_ROOT environment variable is not set. Please install Nintendo Switch SDK.")
endif()

set(NINTENDO_SDK_ROOT $ENV{NINTENDO_SDK_ROOT})
message(STATUS "Nintendo SDK Root: ${NINTENDO_SDK_ROOT}")

# Target system
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Compiler paths
set(COMPILER_ROOT "${NINTENDO_SDK_ROOT}/Compilers/NintendoClang/bin")
set(CMAKE_C_COMPILER "${COMPILER_ROOT}/clang.exe")
set(CMAKE_CXX_COMPILER "${COMPILER_ROOT}/clang++.exe")
set(CMAKE_AR "${COMPILER_ROOT}/llvm-ar.exe")
set(CMAKE_RANLIB "${COMPILER_ROOT}/llvm-ranlib.exe")

# Verify compiler exists
if(NOT EXISTS ${CMAKE_C_COMPILER})
    message(FATAL_ERROR "Compiler not found at ${CMAKE_C_COMPILER}")
endif()

# Target triple
set(CMAKE_C_COMPILER_TARGET "aarch64-nintendo-nx-elf")
set(CMAKE_CXX_COMPILER_TARGET "aarch64-nintendo-nx-elf")

# Compiler flags for Switch
set(SWITCH_ARCH_FLAGS "-march=armv8-a -mtune=cortex-a57")
set(SWITCH_COMMON_FLAGS "${SWITCH_ARCH_FLAGS} -fPIC -D__SWITCH__")

# C flags
set(CMAKE_C_FLAGS_INIT "${SWITCH_COMMON_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "-g -O0")
set(CMAKE_C_FLAGS_RELEASE_INIT "-O2 -DNDEBUG -ffunction-sections -fdata-sections")

# C++ flags
set(CMAKE_CXX_FLAGS_INIT "${SWITCH_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-g -O0")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O2 -DNDEBUG -ffunction-sections -fdata-sections")

# Include directories
include_directories(SYSTEM "${NINTENDO_SDK_ROOT}/Include")

# Set SWITCH_PLATFORM flag for CMakeLists.txt
set(SWITCH_PLATFORM ON CACHE BOOL "Building for Nintendo Switch" FORCE)

# Skip compiler tests (cross-compilation)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

# Static library settings
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

message(STATUS "Switch toolchain configured successfully")
