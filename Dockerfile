# 1. Use the officially recommended base for Zephyr 
FROM ubuntu:24.04 

# Prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# 2. Install ALL system host dependencies required by Zephyr
# This combines the Ubuntu apt install list from the guide
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    wget \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-tk \
    xz-utils \
    file \
    make \
    gcc \
    gcc-multilib \
    g++-multilib \
    libsdl2-dev \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Set home directory as the workspace root
WORKDIR /root

# 3. Create Python virtual environment
RUN python3 -m venv /root/zephyrproject/.venv

# 4. Make virtual environment available to following Docker layers
ENV PATH="/root/zephyrproject/.venv/bin:$PATH"

# 5. Install west
RUN pip install --no-cache-dir west

# 6. Initialize Zephyr workspace and pull Zephyr modules
RUN west init -m https://github.com/zephyrproject-rtos/zephyr /root/zephyrproject \
    && cd /root/zephyrproject \
    && west update

# 7. Install Edge Impulse Zephyr SDK
# Pin to known-good revision for reproducible builds
ARG EI_SDK_COMMIT=76d23c81eebf067646dec3024d594b687c99fd27

RUN mkdir -p /root/zephyrproject/modules \
    && git clone https://github.com/edgeimpulse/edge-impulse-sdk-zephyr.git \
        /root/zephyrproject/modules/edge-impulse-sdk-zephyr \
    && git -C /root/zephyrproject/modules/edge-impulse-sdk-zephyr \
        checkout ${EI_SDK_COMMIT} \
    && test -f /root/zephyrproject/modules/edge-impulse-sdk-zephyr/Kconfig \
    && grep -q "kconfig: Kconfig" \
        /root/zephyrproject/modules/edge-impulse-sdk-zephyr/zephyr/module.yml

# 8. Install Zephyr Python dependencies
RUN cd /root/zephyrproject \
    && west packages pip --install

# 9. Export Zephyr CMake package
RUN cd /root/zephyrproject \
    && west zephyr-export

# 10. Install Zephyr SDK toolchains
RUN cd /root/zephyrproject/zephyr \
    && west sdk install

# 11. Automatically activate virtual environment on shell login
RUN echo "source /root/zephyrproject/.venv/bin/activate" >> /root/.bashrc