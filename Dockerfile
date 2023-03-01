ARG BUILD_IMAGE=nvidia/cuda:11.7.1-devel-ubuntu22.04
ARG BUILD_IMAGE_CU=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

###################
# Builder Stage
FROM ${BUILD_IMAGE} AS builder
ARG DEBIAN_FRONTEND=noninteractive
# Don't write .pyc bytecode
ENV PYTHONDONTWRITEBYTECODE=1
# Create workspace working directory
RUN mkdir /build
WORKDIR /build

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt-get install -y \
    git wget build-essential \
    python3-venv python3-pip \
    gnupg ca-certificates \
    && update-ca-certificates

ARG VIRTUAL_ENV=/workspace/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ADD root_requirements.txt /build
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m venv ${VIRTUAL_ENV}
RUN pip install -U -I torch==1.13.1+cu117 torchvision==0.14.1+cu117 --extra-index-url "https://download.pytorch.org/whl/cu117" && \
    pip install -r root_requirements.txt && \
    pip install --pre --no-deps xformers==0.0.17.dev451
#    In case of emergency, build xformers from scratch
#    export FORCE_CUDA=1 && export TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6" && export CUDA_VISIBLE_DEVICES=0 && \
#    pip install --no-deps git+https://github.com/facebookresearch/xformers.git@48a77cc#egg=xformers


###################
# Runtime Stage
FROM nvidia/cuda:11.7.1-runtime-ubuntu22.04 as runtime
ARG MAIN_VENV_PATH=/workspace/venv
ARG SDUI_VENV_PATH=/workspace/stable-diffusion-webui/venv

# Use bash shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND noninteractive\
    SHELL=/bin/bash

# Python logs go strait to stdout/stderr w/o buffering
ENV PYTHONUNBUFFERED=1

# Don't write .pyc bytecode
ENV PYTHONDONTWRITEBYTECODE=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt install -y --no-install-recommends \
    wget bash zsh curl git git-lfs vim tmux \
    build-essential lsb-release \
    python3-pip python3-venv \
    openssh-server \
    libgl1 libglib2.0-0 python-is-python3 python3-opencv \
    gnupg ca-certificates && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.9.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

ENV PATH="$MAIN_VENV_PATH/bin:$PATH"
COPY --from=builder ${MAIN_VENV_PATH} ${MAIN_VENV_PATH}
RUN echo "source ${MAIN_VENV_PATH}/bin/activate" >> /root/.bashrc
# Workaround for:
#   https://github.com/TimDettmers/bitsandbytes/issues/62
#   https://github.com/TimDettmers/bitsandbytes/issues/73
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.7/targets/x86_64-linux/lib"
RUN ln /usr/local/cuda-11.7/targets/x86_64-linux/lib/libcudart.so.11.0 /usr/local/cuda-11.7/targets/x86_64-linux/lib/libcudart.so
RUN pip install bitsandbytes==0.37.0

RUN git clone https://github.com/victorchall/EveryDream2trainer /workspace/EveryDream2trainer
WORKDIR /workspace/EveryDream2trainer
RUN python utils/get_yamls.py && \
    mkdir -p logs && mkdir -p input
RUN echo "deactivate" >> /root/.bashrc

## lets do SDUI
RUN mkdir -p /workspace/local_ckpts && mkdir -p /workspace/outputs && mkdir -p /workspace/invoke
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui && \
    git clone https://github.com/guaneec/custom-diffusion-webui.git /workspace/stable-diffusion-webui/extensions/custom-diffusion-webui && \
    git clone https://github.com/camenduru/sd-civitai-browser.git /workspace/stable-diffusion-webui/extensions/sd-civitai-browser && \
    git clone https://github.com/adieyal/sd-dynamic-prompts.git /workspace/stable-diffusion-webui/extensions/sd-dynamic-prompts && \
    git clone https://github.com/camenduru/sd-webui-additional-networks.git /workspace/stable-diffusion-webui/extensions/sd-webui-additional-networks && \
    git clone https://github.com/d8ahazard/sd_dreambooth_extension.git /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension && \
    git clone https://github.com/catppuccin/stable-diffusion-webui.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui && \
    git clone https://github.com/toriato/stable-diffusion-webui-daam.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-daam && \
    git clone https://github.com/CodeExplode/stable-diffusion-webui-embedding-editor.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-embedding-editor && \
    git clone https://github.com/camenduru/stable-diffusion-webui-huggingface.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-huggingface && \
    git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-promptgen.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-promptgen && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-tokenizer.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-tokenizer && \
    git clone https://github.com/benkyoujouzu/stable-diffusion-webui-visualize-cross-attention-extension.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-visualize-cross-attention-extension


RUN python3 -m venv /workspace/stable-diffusion-webui/venv
ENV PATH="$SDUI_VENV_PATH/bin:$PATH"
RUN echo "source ${SDUI_VENV_PATH}/bin/activate" >> /root/.bashrc

WORKDIR /workspace/stable-diffusion-webui
COPY install-webui.py ./install.py
RUN python -m install --skip-torch-cuda-test
RUN echo "deactivate" >> /root/.bashrc

RUN ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion
COPY webui-user.sh /workspace/stable-diffusion-webui/webui-user.sh
COPY config.json /workspace/stable-diffusion-webui/config.json
COPY ui-config.json /workspace/stable-diffusion-webui/ui-config.json
COPY relauncher-webui.py /workspace/stable-diffusion-webui/relauncher.py

ADD start.sh /
RUN chmod +x /start.sh  
WORKDIR /workspace

CMD [ "/start.sh" ]