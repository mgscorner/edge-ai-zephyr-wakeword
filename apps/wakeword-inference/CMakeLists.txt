cmake_minimum_required(VERSION 3.20.0)

list(APPEND ZEPHYR_EXTRA_MODULES
    ${CMAKE_CURRENT_SOURCE_DIR}/wake-word
    ${CMAKE_CURRENT_SOURCE_DIR}/../modules/edge-impulse-sdk-zephyr
)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(edge_ai_demo)

target_sources(app PRIVATE
    src/main.cpp
  
)