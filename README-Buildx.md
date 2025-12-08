用 Docker 在 M1 上交叉到 Linux/amd64

### 3.1 准备 Dockerfile（放在 hwm14 仓库根目录）

```dockerfile
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
```

### 3.2 用 buildx 在 M1 上交叉构建

第一次需要创建一个 builder（只需做一次）：

```bash
docker buildx create --name hwm-builder --use
```

然后在 hwm14 仓库根目录执行：

```bash
docker buildx build \
  --platform linux/amd64 \
  -t hwm14-linux-amd64 \
  .
```

这样你在 M1 上就构建出了一个 **linux/amd64** 的镜像，里面有：

* `/app/hwm14test`
* `/app/hwm14check`
* `/app/libhwm14.a`

把这个镜像推到你的私有仓库（例如 Docker Hub 或公司 registry），
在 Linux 服务器上 `docker run hwm14-linux-amd64` 就能直接用。

> 这个就是“在 M1 上交叉编译到 Linux/amd64”，只是把所有复杂度交给 Docker + QEMU 了。

---

## 4. 如果你只想要二进制，不想用 Docker？

那也可以从这个镜像里把文件“抠出来”：

在 M1 上：

```bash
# 构建完镜像
docker create --name tmp-hwm hwm14-linux-amd64
docker cp tmp-hwm:/app/hwm14test ./hwm14test_linux_amd64
docker cp tmp-hwm:/app/hwm14check ./hwm14check_linux_amd64
docker cp tmp-hwm:/app/libhwm14.a ./libhwm14_linux_amd64.a
docker rm tmp-hwm
```

这三个就是标准的 **Linux/amd64 ELF** 文件，可以直接丢到 Linux 机器上跑。

---

## 5. 想要 Windows 可执行文件呢？

大致流程是：

1. 在 macOS 上用 Homebrew 装 mingw-w64：

   ```bash
   brew install mingw-w64
   ```

   会有类似：`x86_64-w64-mingw32-gfortran`

2. 写一个 CMake toolchain 文件 `toolchain-mingw.cmake`：

   ```cmake
   set(CMAKE_SYSTEM_NAME Windows)
   set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
   set(CMAKE_Fortran_COMPILER x86_64-w64-mingw32-gfortran)
   ```

3. 用它生成工程：

   ```bash
   cmake -B build-win -S . -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw.cmake
   cmake --build build-win --config Release
   ```

就能得到 `.exe` / `.a`，但这一步通常只在你确实要 Windows 部署时再搞，不然没必要自找麻烦。