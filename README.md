# Introduction

teensy-cmake is a template for Teensy projects that uses CMake to build your sketches.
This lets you develop for Teensy using your favorite text editor and terminal.
It can easily accommodate executables built from several source and header files.

Teensy sketches from Teensyduino have been included to get started quickly.

It has currently only been tested on Linux with a Teensy 3.1.

# Requirements

* CMake
* Git
* A cross-compiler toolchain for ARM ('arm-none-eabi')
* Teensyduino for sketches that use libraries (e.g. Bounce)

# Setup

Clone this repository from GitHub:

```bash
git clone https://github.com/xya/teensy-cmake.git
cd teensy-cmake
```

If you don't have Teensystudio installed, clone the Teensy 'cores' repository from GitHub:

```bash
git clone https://github.com/PaulStoffregen/cores.git
```

Create a build directory:

```bash
mkdir -p build/debug
cd build/debug
```

Run CMake (with the toolchain file):
```bash
cmake ../.. -DCMAKE_TOOLCHAIN_FILE=../../teensy-arm.toolchain.cmake -DCMAKE_BUILD_TYPE:STRING=Debug 
```

This last step might fail with errors such as 'compiler not found'. In this case, run the CMake GUI:

```bash
cmake-gui ../..
```

Make sure that 'TEENSY_CORES_ROOT' points to the 'cores' directory from Arduino (e.g. /usr/share/arduino/hardware/teensy/cores), or to the directory where you cloned the 'cores' directory.

To build sketches that use libraries, make sure that 'ARDUINO_LIB_ROOT' points to the Arduino library directory (e.g. /usr/share/arduino/libraries).

Finally, build all example sketches with:
```bash
make -j
```

# Flashing sketches to the Teensy

TODO: This is not yet supported.

# Creating new single-file sketches

To create new sketches, simply create a new directory inside 'sketches' (e.g. sketches/MySketch) that contains the sketch file (e.g. sketches/MySketch/MySketch.ino). It will be automatically be picked up the next time you run CMake. The sketch can be a C++ file too, in which case you need to import 'Arduino.h' and declare the 'setup'/'loop' functions.

# Creating new multi-file C/C++ projects

You can create new multi-file projects in the same way than single-file sketches. The only difference is you need to create a 'CMakeLists.txt' file inside the project folder with contents like:

```
add_teensy_executable(MyProject
    MyProject.cpp
    MyProject_sensors.cpp
    MyProject_interrupts.cpp)
```

# Custom configuration

For some sketches, the Teensy needs to run in a different 'USB mode'. You can set this in the sketch's CMakeLists.txt file:

```
set(TEENSY_USB_MODE MIDI)

add_sketch() # or add_teensy_executable(...)
```

You can set the 'default' mode in the CMake GUI ('TEENSY_USB_MODE' variable).

# Importing libraries

Here is a simple example of how to import a library:

```
import_arduino_library(Bounce)

add_sketch() # or add_teensy_executable(...)
```

Make sure that the 'ARDUINO_LIB_ROOT' variable is set up correctly in CMake.

# Creating bare C/C++ projects

With 'bare' projects you have to define 'main' and include headers yourself.

TODO: This is not yet supported.

