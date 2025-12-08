# Dockerfile  ——  在 M1 上交叉构建 Linux/amd64 的 HWM14

FROM ubuntu:22.04 AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        cmake \
        git && \
    rm -rf /var/lib/apt/lists/*

# 把当前 hwm14 源码拷进去
WORKDIR /src
COPY . .

# 标准的 cmake 构建流程
RUN cmake -B build -S . && \
    cmake --build build --config Release

# 把产物整理到 /out 目录
RUN mkdir -p /out && \
    cp build/hwm14test /out/ && \
    cp build/hwm14check /out/ && \
    cp build/libhwm14.a /out/

# 一个精简的运行镜像（可选）
FROM ubuntu:22.04 AS runtime
WORKDIR /app
COPY --from=build /out/ /app/

# 暂时就提供一个命令行入口
ENTRYPOINT ["/app/hwm14test"]
