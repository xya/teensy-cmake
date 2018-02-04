# Copyright (c) 2015, Pierre-Andre Saulais <pasaulais@free.fr>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#-------------------------------------------------------------------------------------------------------------------------
# user-defined settings

set(ARDUINO_ROOT "/usr/share/arduino/")
#set(TOOLCHAIN_ROOT "${ARDUINO_ROOT}/hardware/tools/arm")
#note: to make a non-arduino compiler work: copy libarm_*_math.a from ${ARDUINO_ROOT}//hardware/tools/arm/arm-none-eabi/lib to ${TOOLCHAIN_ROOT}/arm-none-eabi/lib
set(TOOLCHAIN_ROOT "/usr")
set(TEENSY_CORES_ROOT "${ARDUINO_ROOT}/hardware/teensy/avr/cores" CACHE PATH "Path to the Teensy 'cores' repository")
set(ARDUINO_LIB_ROOT "${ARDUINO_ROOT}/hardware/teensy/avr/libraries" CACHE PATH "Path to the Arduino library directory")
set(ARDUINO_VERSION "106" CACHE STRING "Version of the Arduino SDK")
set(TEENSYDUINO_VERSION "120" CACHE STRING "Version of the Teensyduino SDK")
set(TEENSY_BOARD "3.6")

#-------------------------------------------------------------------------------------------------------------------------

set(TEENSY_MODEL)
set(TEENSY_FREQUENCY "0" CACHE STRING "Frequency of the Teensy MCU (Mhz)")
if(${TEENSY_BOARD} STREQUAL 3.6)
  set(TEENSY_MODEL "MK66FX1M0")
  set(TEENSY_FREQUENCY "180")
  set_property(CACHE TEENSY_FREQUENCY PROPERTY STRINGS 180 168 144 120 96 72 48 24 16 8 4 2)
elseif(${TEENSY_BOARD} STREQUAL 3.5)
  set(TEENSY_MODEL "MK64FX512")
  set(TEENSY_FREQUENCY "120")
  set_property(CACHE TEENSY_FREQUENCY PROPERTY STRINGS 120 96 72 48 24 16 8 4 2)
elseif(${TEENSY_BOARD} STREQUAL 3.2)
  set(TEENSY_MODEL "MK20DX256")
  set(TEENSY_FREQUENCY "72")
  set_property(CACHE TEENSY_FREQUENCY PROPERTY STRINGS 96 72 48 24 16 8 4 2)
elseif(${TEENSY_BOARD} STREQUAL 3.1)
  set(TEENSY_MODEL "MK20DX128")
  set(TEENSY_FREQUENCY "72")
  set_property(CACHE TEENSY_FREQUENCY PROPERTY STRINGS 96 72 48 24 16 8 4 2)
else()
  message(FATAL_ERROR "Unknown board model: ${TEENSY_BOARD}")
endif()

set(TEENSY_USB_MODE "SERIAL" CACHE STRING "What kind of USB device the Teensy should emulate")
set_property(CACHE TEENSY_USB_MODE PROPERTY STRINGS SERIAL HID SERIAL_HID MIDI RAWHID FLIGHTSIM)

if(WIN32)
    set(TOOL_OS_SUFFIX .exe)
else(WIN32)
    set(TOOL_OS_SUFFIX )
endif(WIN32)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)

set(TRIPLE "arm-none-eabi")

set(CMAKE_C_COMPILER "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-gcc${TOOL_OS_SUFFIX}" CACHE PATH "gcc" FORCE)
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-g++${TOOL_OS_SUFFIX}" CACHE PATH "g++" FORCE)
set(CMAKE_AR "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-gcc-ar${TOOL_OS_SUFFIX}" CACHE PATH "archive" FORCE)
set(CMAKE_LINKER "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-ld${TOOL_OS_SUFFIX}" CACHE PATH "linker" FORCE)
set(CMAKE_NM "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-gcc-nm${TOOL_OS_SUFFIX}" CACHE PATH "nm" FORCE)
set(CMAKE_OBJCOPY "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-objcopy${TOOL_OS_SUFFIX}" CACHE PATH "objcopy" FORCE)
set(CMAKE_OBJDUMP "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-objdump${TOOL_OS_SUFFIX}" CACHE PATH "objdump" FORCE)
set(CMAKE_STRIP "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-strip${TOOL_OS_SUFFIX}" CACHE PATH "strip" FORCE)
set(CMAKE_RANLIB "${TOOLCHAIN_ROOT}/bin/${TRIPLE}-gcc-ranlib${TOOL_OS_SUFFIX}" CACHE PATH "ranlib" FORCE)

set(TEENSY_ROOT "${TEENSY_CORES_ROOT}/teensy3")

include_directories("${TEENSY_ROOT}")

set(TARGET_FLAGS "-mcpu=cortex-m4 -mthumb")
set(OPT_LEVEL "-Os")
set(BASE_FLAGS "${OPT_LEVEL} -Wall -nostdlib -ffunction-sections -fdata-sections ${TARGET_FLAGS}")

set(CMAKE_C_FLAGS "${BASE_FLAGS} -DTIME_T=1421620748" CACHE STRING "c flags") # XXX Generate TIME_T dynamically.
set(CMAKE_CXX_FLAGS "${BASE_FLAGS} -fno-exceptions -fno-rtti -felide-constructors -std=gnu++14" CACHE STRING "c++ flags")

string(TOLOWER ${TEENSY_MODEL} TEENSY_MODEL_LOWER)
set(LINKER_FLAGS "${OPT_LEVEL} -Wl,--gc-sections ${TARGET_FLAGS} -T\"${TEENSY_ROOT}/${TEENSY_MODEL_LOWER}.ld\"" )
set(LINKER_LIBS "-larm_cortexM4l_math -lm" )
set(CMAKE_SHARED_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "linker flags" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "linker flags" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "linker flags" FORCE)

# Do not pass flags like '-ffunction-sections -fdata-sections' to the linker.
# This causes undefined symbol errors when linking.
#link with CXX compiler and not C compiler (needed when rtti is enabled, does not change anything otherwise)
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> -o <TARGET>  <OBJECTS> <LINK_LIBRARIES> ${LINKER_LIBS}" CACHE STRING "Linker command line" FORCE)

#if using a windows compiler under a unix shell, paths written in template files must be converted to native windows paths
set(CONVERT_PATHS_TO_WIN FALSE)
if(UNIX)
  if((NOT DEFINED ${CYGWIN}) AND (NOT DEFINED ${MINGW}))
    #note: CYGWIN and MINGW are variables, but UNIX seems to be a macro
    set(CONVERT_PATHS_TO_WIN TRUE)
  endif()
endif()

add_definitions("-DARDUINO=${ARDUINO_VERSION}")
add_definitions("-DTEENSYDUINO=${TEENSYDUINO_VERSION}")
add_definitions("-D__${TEENSY_MODEL}__")
add_definitions(-DLAYOUT_US_ENGLISH)
add_definitions(-DUSB_VID=null)
add_definitions(-DUSB_PID=null)
add_definitions(-MMD)
