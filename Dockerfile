# syntax = docker/dockerfile:experimental
FROM --platform=linux/amd64 debian:bullseye AS cargo-builder

# Install nightly toolchain for Rust
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl git ca-certificates --no-install-recommends
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && chmod +x rustup.sh && ./rustup.sh -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:$PATH"

# Setup ARMV5TE cross-compilation environment
RUN rustup target add armv5te-unknown-linux-gnueabi --toolchain nightly
RUN dpkg --add-architecture armel
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y gcc-arm-linux-gnueabi pkg-config libc6-dev-armel-cross crossbuild-essential-armel
RUN echo '[target.armv5te-unknown-linux-gnueabi]\nlinker = "arm-linux-gnueabi-gcc"' >> /root/.cargo/config
RUN cargo install cargo-deb
ENV PKG_CONFIG_ALLOW_CROSS="true"
ENV PKG_CONFIG_PATH="/usr/lib/arm-linux-gnueabi/pkgconfig"

# Build latest Cargo
RUN git clone https://github.com/rust-lang/cargo
WORKDIR /cargo
RUN echo '\
[package.metadata.deb]\n\
maintainer = "rara"\n\
copyright = "MIT OR Apache-2.0"\n\
extended-description = """\n\
Cargo, a package manager for Rust.\n\
"""' >> Cargo.toml
RUN cargo deb --target armv5te-unknown-linux-gnueabi -- --features=vendored-openssl

FROM --platform=linux/arm/v5 python:3.10-bullseye
ARG NUMPY_VER
ARG PANDAS_VER
ARG PYNACL_VER
ARG CRYPTO_VER
ARG ORJSON_VER
ARG PILLOW_VER

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y rustc cargo build-essential cmake --no-install-recommends
COPY --from=cargo-builder /cargo/target/armv5te-unknown-linux-gnueabi/debian/*.deb .
RUN dpkg -i *.deb

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install numpy==$NUMPY_VER
RUN pip install pandas==$PANDAS_VER
RUN pip install pynacl==$PYNACL_VER
RUN pip install cryptography==$CRYPTO_VER
RUN pip install orjson==$ORJSON_VER
RUN pip install pillow==$PILLOW_VER
