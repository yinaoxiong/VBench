# syntax=docker.io/docker/dockerfile:1.7-labs
FROM nvcr.io/nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG UBUNTU_MIRROR=""

# Install dependencies
RUN if [ -n "$UBUNTU_MIRROR" ]; then \
    sed -i "s|http://archive.ubuntu.com/ubuntu/|${UBUNTU_MIRROR}|g; s|http://security.ubuntu.com/ubuntu/|${UBUNTU_MIRROR}|g" /etc/apt/sources.list; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    libgl1 \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.7.18 /uv /uvx /bin/

WORKDIR /workspace
USER root
# Copy the vbench cache directory; avoid creating a layer larger than 10GB
COPY --exclude="vbench" vb_cache/ /root/.cache/
COPY vb_cache/vbench /root/.cache/vbench

COPY --exclude="vb_cache/" . ./

# Install Python dependencies
RUN --mount=type=cache,id=uv-cache,target=/root/.cache/uv uv sync && \
    uv add detectron2

