FROM --platform=linux/arm/v5 python:3.10-bullseye
ARG NUMPY_VER
ARG PANDAS_VER
ARG PYNACL_VER
ARG CRYPTO_VER
ARG ORJSON_VER
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y build-essential cmake --no-install-recommends
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install numpy==$NUMPY_VER
RUN pip install pandas==$PANDAS_VER
RUN pip install pynacl==$PYNACL_VER
RUN pip install cryptography==$CRYPTO_VER
RUN pip install orjson==$ORJSON_VER
