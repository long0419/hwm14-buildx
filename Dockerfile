FROM ubuntu:22.04

WORKDIR /src

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        cmake \
        git && \
    rm -rf /var/lib/apt/lists/*

COPY . .

RUN cmake -B build -S . && \
    cmake --build build --config Release

RUN mkdir -p /app && \
    cp build/hwm14test  /app/ && \
    cp build/hwm14check /app/ && \
    cp build/libhwm14.a /app/

WORKDIR /app
ENTRYPOINT ["/app/hwm14test"]