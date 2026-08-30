# Edge Impulse Wake-Word Inference on Zephyr

Running an INT8 Edge Impulse wake-word model on Zephyr for a QEMU-emulated
Cortex-M33 target, with simulated microphone input.

The project focuses on the complete embedded ML workflow: 
* building the target environment, 
* training a small audio model, 
* integrating it into Zephyr, and 
* running inference without requiring physical MCU hardware.
  
## Overview

The wake-word model was created and trained in Edge Impulse using recorded 
audio samples for the keyword **"okydoky"** together with background/noise 
samples.

The target environment runs completely inside Docker:

    Docker
      |
      +-- Zephyr build environment
      |
      +-- QEMU
            |
            +-- Cortex-M33
                  |
                  +-- Zephyr application
                        |
                        +-- Edge Impulse inference

The current QEMU target is Cortex-M33. The same approach can later be used with
other Cortex-M targets such as M4.

## Development Setup

The development environment is packaged in a Docker container containing:

- Zephyr build system and SDK
- West, CMake and Ninja
- QEMU
- Application source code
- Edge Impulse model and SDK

Before adding ML inference, a minimal Zephyr `main.cpp` application was compiled
and executed on the QEMU target to verify the toolchain and emulation environment.

## Edge Impulse - Wake-Word Model

The wake-word model was:

1. Created and trained in Edge Impulse from recorded audio samples.
  * Audio preprocessing uses MFCC (Mel Frequency Cepstral Coefficients)
2. Validated using a separate test data set.
3. Quantized for **INT8 inference**.
4. Compiled using the **EON Compiler**.
5. Exported as an **Edge Impulse Zephyr library**.

EON generates optimized code for the trained network instead of relying only on
the generic TensorFlow Lite Micro interpreter. For this model, Edge Impulse
reported approximately **40% lower RAM** and **50% lower ROM/flash usage**.

## Zephyr Integration

The integration required:

- registering the generated model as a Zephyr module
- adding the Edge Impulse Zephyr SDK
- enabling the full C++ standard library
- enabling the Edge Impulse SDK configuration
- allocating sufficient stack and heap memory for inference

The model and Edge Impulse runtime now compile and link successfully into the
Zephyr firmware. 
The Edge Impulse Zephyr deployment package is generated separately and placed in:
app/wake-word/
The shared Edge Impulse Zephyr SDK is checked out as an external dependency.

## Current Status

- [x] Docker-based Zephyr development environment
- [x] QEMU Cortex-M33 target
- [x] Basic Zephyr C/C++ application running in QEMU
- [x] Wake-word training and testing in Edge Impulse
- [x] INT8 / EON model generation
- [x] Edge Impulse Zephyr integration
- [x] Model compiled and linked into Zephyr firmware
- [ ] Simulated microphone input
- [ ] Feed recorded audio into the emulated target
- [ ] Run wake-word inference
- [ ] Forward inference results to the surrounding edge cluster

## Next Step: Simulated Microphone

Connecting a real microphone or passing through a USB microphone works in 
embedded pc setup, but since this model is intended to run on a M33 this
is not an option. Instead, a mock microphone interface will provide 
simulated or recorded audio data to the Zephyr application.

The intended test path is:

    recorded audio
         |
         v
    mock microphone
         |
         v
    Zephyr input path
         |
         v
    Edge Impulse model
         |
         v
    wake-word inference
         |
         v
    detection result

This makes it possible to test the complete embedded inference path in QEMU
before moving the same application to physical hardware.

# References 
### Getting Started Guide - Setup a command-line Zephyr development environment 
https://docs.zephyrproject.org/latest/develop/getting_started/index.html
### Edge Impulse - Create Application
https://docs.edgeimpulse.com/hardware/deployments/run-cpp
