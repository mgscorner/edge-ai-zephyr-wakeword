cmake_minimum_required(VERSION 3.20.0)

list(APPEND ZEPHYR_EXTRA_MODULES
    /root/zephyrproject/modules/edge-impulse-sdk-zephyr
    ${CMAKE_CURRENT_SOURCE_DIR}/wake-word
)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(wakeword_inference)

target_sources(app PRIVATE
    src/main.cpp
)