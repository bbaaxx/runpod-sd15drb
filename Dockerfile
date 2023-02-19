
# ARG BASE_IMAGE=tensorflow/tensorflow:latest-gpu
ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

FROM alpine:latest as checkpoint_holder
RUN mkdir /dlt
ADD https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors /dlt/v1-5-pruned-emaonly.safetensors

FROM ${BASE_IMAGE} as base-deps-container
ENV DEBIAN_FRONTEND noninteractive
# ENV TZ=America/MexicoCity
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update --yes && apt-get upgrade --yes  &&  apt-get install --yes \
    net-tools vim man file sudo unzip sed \
    wget curl git git-lfs tmux gpg zsh openssh-server \
    libgl1 libglib2.0-0 python3-pip python-is-python3 python3-venv python3-opencv && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

FROM base-deps-container as app-deps-container
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

FROM app-deps-container as run-container

COPY launcher-webui.py /workspace/stable-diffusion-webui/launcher.py
COPY webui-user.template /workspace/stable-diffusion-webui/webui-user.sh
# RUN sed -i -e '''/prepare_environment()/a\    os.system\(f\"""sed -i -e ''\"s/dict()))/dict())).cuda()/g\"'' /workspace/stable-diffusion-webui/repositories/stable-diffusion-stability-ai/ldm/util.py""")''' /workspace/stable-diffusion-webui/launch.py
RUN sed -i -e 's/    start()/    #start()/g' /workspace/stable-diffusion-webui/launch.py
RUN cd /workspace/stable-diffusion-webui && python launcher.py --skip-torch-cuda-test
RUN sed -i -e 's/    #start()/    start()/g' /workspace/stable-diffusion-webui/launch.py
RUN ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion

COPY  --from=checkpoint_holder /dlt/v1-5-pruned-emaonly.safetensors /workspace/local_ckpts/v1-5-pruned-emaonly.safetensors
# ADD https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors /workspace/local_ckpts/v1-5-pruned-emaonly.safetensors

# RUN useradd -m -s /bin/bash poduser && usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/poduser && chmod 044 /etc/sudoers.d/poduser

# COPY --from=build-base /workspace /workspace
# COPY --from=build-base --chown=poduser:poduser /workspace /workspace


# COPY relauncher-invoke.py /workspace/invoke/relauncher.py
COPY relauncher-webui.py /workspace/stable-diffusion-webui/relauncher.py
COPY start.sh /

RUN chmod +x /start.sh 

WORKDIR /workspace

CMD [ "/start.sh" ]