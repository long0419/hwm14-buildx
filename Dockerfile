# Dockerfile —— 在 M1 上交叉构建 Linux/amd64 的 HWM14（单阶段构建）

FROM ubuntu:22.04

# 工作目录
WORKDIR /src

# 安装构建依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        cmake \
        git && \
    rm -rf /var/lib/apt/lists/*

# 拷贝源码
COPY . .

# 标准的 CMake 构建流程
RUN cmake -B build -S . && \
    cmake --build build --config Release

# 把产物整理到 /app 目录，作为运行入口目录
RUN mkdir -p /app && \
    cp build/hwm14test  /app/ && \
    cp build/hwm14check /app/ && \
    cp build/libhwm14.a /app/

WORKDIR /app

# 提供命令行入口
ENTRYPOINT ["/app/hwm14test"]