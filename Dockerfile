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

# 3. Create the python venv (Step 1 from the guide)
RUN python3 -m venv /root/zephyrproject/.venv

# 4. Permanently update PATH for Docker build layers (Replaces 'source activate')
ENV PATH="/root/zephyrproject/.venv/bin:$PATH"

# 5. Install west (Step 3 from the guide)
RUN pip install --no-cache-dir west

# 6. Initialize workspace & pull modules (Step 4 from the guide)
# Note: Chaining with && ensures the context doesn't lose the directory change
RUN west init -m https://github.com/zephyrproject-rtos/zephyr /root/zephyrproject \
    && cd /root/zephyrproject \
    && west update

# 7. Install Zephyr's exact Python dependencies (Step 5 from the guide)
RUN cd /root/zephyrproject \
    && west packages pip --install

# 8. Export Zephyr CMake package (Step 6 from the guide)
RUN cd /root/zephyrproject \
    && west zephyr-export

# 9. Install the Zephyr SDK Toolchains (From the SDK Section)
RUN cd /root/zephyrproject/zephyr \
    && west sdk install

# 10. AUTO-ACTIVATION FOR YOU: Ensure that when you log into the container,
# the virtual environment is fully active and the prompt reflects it.
RUN echo "source /root/zephyrproject/.venv/bin/activate" >> /root/.bashrc
