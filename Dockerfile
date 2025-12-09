FROM ubuntu:22.04

# 构建目录
WORKDIR /src

# 安装构建依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        cmake \
        git && \
    rm -rf /var/lib/apt/lists/*

# 拷贝整个工程（包含 src/、data/、CMakeLists.txt 等）
COPY . .

# CMake 构建
RUN cmake -B build -S . && \
    cmake --build build --config Release

# 准备运行目录，把可执行文件 + 数据文件拷过去
RUN mkdir -p /app && \
    cp build/hwm14test  /app/ && \
    cp build/hwm14check /app/ && \
    cp build/libhwm14.a /app/ && \
    cp -r data /app/data

# 告诉 HWM14 数据文件在哪里（有些实现会用这个环境变量）
ENV HWMPATH=/app/data

# 运行目录：让程序在 /app 下运行
WORKDIR /app

# 默认入口
ENTRYPOINT ["/app/hwm14test"]
