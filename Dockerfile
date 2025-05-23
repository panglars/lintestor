# 使用 ubuntu:latest 作为基础镜像
FROM ubuntu:latest

# 避免在构建过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装基本软件包和交叉编译工具链
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    curl \
    git \
    libssl-dev \
    pkg-config \
    cmake \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu \
    g++-riscv64-linux-gnu \
    gcc-powerpc64-linux-gnu \
    g++-powerpc64-linux-gnu \
    gcc-i686-linux-gnu \
    g++-i686-linux-gnu \
    libc6-dev-i386 \
    && rm -rf /var/lib/apt/lists/*

# 添加 PPA 并安装 GCC 14 和相关工具
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y \
    gcc-14 \
    g++-14 \
    gcc-14-aarch64-linux-gnu \
    g++-14-aarch64-linux-gnu \
    gcc-14-arm-linux-gnueabihf \
    g++-14-arm-linux-gnueabihf \
    gcc-14-riscv64-linux-gnu \
    g++-14-riscv64-linux-gnu \
    gcc-14-powerpc64-linux-gnu \
    g++-14-powerpc64-linux-gnu \
    gcc-14-i686-linux-gnu \
    g++-14-i686-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /root

# 安装 Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly

# 将 Rust 二进制文件添加到 PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# 添加所有目标架构
RUN rustup target add \
    x86_64-unknown-linux-gnu \
    i686-unknown-linux-gnu \
    aarch64-unknown-linux-gnu \
    armv7-unknown-linux-gnueabihf \
    riscv64gc-unknown-linux-gnu \
    powerpc64-unknown-linux-gnu

# 配置 Cargo 以使用正确的链接器
RUN mkdir -p ~/.cargo && echo '\
[target.aarch64-unknown-linux-gnu]\n\
linker = "aarch64-linux-gnu-gcc-14"\n\
[target.armv7-unknown-linux-gnueabihf]\n\
linker = "arm-linux-gnueabihf-gcc-14"\n\
[target.riscv64gc-unknown-linux-gnu]\n\
linker = "riscv64-linux-gnu-gcc-14"\n\
[target.powerpc64-unknown-linux-gnu]\n\
linker = "powerpc64-linux-gnu-gcc-14"\n\
[target.i686-unknown-linux-gnu]\n\
linker = "i686-linux-gnu-gcc-14"' > ~/.cargo/config.toml

# 设置默认命令
CMD ["/bin/bash"]
