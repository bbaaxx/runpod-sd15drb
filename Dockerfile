
# ARG BASE_IMAGE=tensorflow/tensorflow:latest-gpu
ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

FROM ${BASE_IMAGE} as base-deps-container
ENV DEBIAN_FRONTEND noninteractive
# ENV TZ=America/MexicoCity
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update --yes && apt-get upgrade --yes  &&  apt-get install --yes \
    net-tools vim man file sudo unzip sed \
    wget curl git git-lfs tmux gpg zsh openssh-server \
    libgl1 libglib2.0-0 python3-pip python-is-python3 python3-venv python3-opencv && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen



RUN mkdir -p /workspace/local_ckpts && mkdir -p /workspace/outputs && mkdir -p /workspace/invoke
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui && \
    git clone https://github.com/guaneec/custom-diffusion-webui.git /workspace/stable-diffusion-webui/extensions/custom-diffusion-webui && \
    git clone https://github.com/deforum-art/deforum-for-automatic1111-webui.git /workspace/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui && \
    git clone https://github.com/camenduru/sd-civitai-browser.git /workspace/stable-diffusion-webui/extensions/sd-civitai-browser && \
    git clone https://github.com/adieyal/sd-dynamic-prompts.git /workspace/stable-diffusion-webui/extensions/sd-dynamic-prompts && \
    git clone https://github.com/camenduru/sd-webui-additional-networks.git /workspace/stable-diffusion-webui/extensions/sd-webui-additional-networks && \
    git clone https://github.com/d8ahazard/sd_dreambooth_extension.git /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension && \
    git clone https://github.com/catppuccin/stable-diffusion-webui.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui && \
    git clone https://github.com/toriato/stable-diffusion-webui-daam.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-daam && \
    git clone https://github.com/CodeExplode/stable-diffusion-webui-embedding-editor.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-embedding-editor && \
    git clone https://github.com/camenduru/stable-diffusion-webui-huggingface.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-huggingface && \
    git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser && \
    git clone https://github.com/yfszzx/stable-diffusion-webui-inspiration.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-inspiration && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-promptgen.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-promptgen && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-tokenizer.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-tokenizer && \
    git clone https://github.com/benkyoujouzu/stable-diffusion-webui-visualize-cross-attention-extension.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-visualize-cross-attention-extension

RUN python3 -m venv /workspace/stable-diffusion-webui/venv
ENV PATH="/workspace/stable-diffusion-webui/venv/bin:$PATH"

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    pip install -U jupyterlab ipywidgets jupyter-archive && \
    jupyter nbextension enable --py widgetsnbextension
WORKDIR /workspace/stable-diffusion-webui

COPY install-webui.py ./install.py
RUN python -m install --skip-torch-cuda-test

RUN apt clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen


FROM base-deps-container as run-container

COPY webui-user.sh /workspace/stable-diffusion-webui/webui-user.sh
COPY config.json /workspace/stable-diffusion-webui/config.json
COPY ui-config.json /workspace/stable-diffusion-webui/ui-config.json
RUN ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion


COPY relauncher-webui.py /workspace/stable-diffusion-webui/relauncher.py
COPY start.sh /start.sh
RUN chmod +x /start.sh  
WORKDIR /workspace

CMD [ "/start.sh" ]