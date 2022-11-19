FROM --platform=linux/arm/v5 python:3.10-bullseye
ARG version
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y build-essential cmake --no-install-recommends
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install pandas==$version
