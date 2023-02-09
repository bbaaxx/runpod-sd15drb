
ARG BASE_IMAGE=tensorflow/tensorflow:latest-gpu

ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04
FROM ${BASE_IMAGE} as dev-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND noninteractive\
    SHELL=/bin/bash

# RUN apt-key del 7fa2af80
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends\
    wget git git-lfs vim gpg \
    libgl1 libglib2.0-0 python3-pip python-is-python3 \
    bash\
    openssh-server &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN pip3 install --upgrade pip

RUN pip install jupyterlab
RUN pip install ipywidgets
RUN pip install --pre triton
RUN pip install numexpr

ADD start.sh /
RUN chmod +x /start.sh

WORKDIR /workspace


RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui
COPY webui-user.template /workspace/stable-diffusion-webui/webui-user.sh
COPY relauncher.py /workspace/stable-diffusion-webui/relauncher.py
RUN sed -i -e 's/    start()/    #start()/g' /workspace/stable-diffusion-webui/launch.py
RUN cd stable-diffusion-webui && python launch.py --skip-torch-cuda-test
RUN sed -i -e 's/    #start()/    start()/g' /workspace/stable-diffusion-webui/launch.py

# RUN git clone https://github.com/camenduru/deforum-for-automatic1111-webui /workspace/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui
# RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension
# RUN git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser
# RUN git clone https://github.com/camenduru/stable-diffusion-webui-huggingface /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-huggingface
# RUN git clone https://github.com/camenduru/sd-civitai-browser /workspace/stable-diffusion-webui/extensions/sd-civitai-browser
# RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-promptgen.git /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-promptgen
# RUN git clone https://github.com/camenduru/sd-webui-additional-networks /workspace/stable-diffusion-webui/extensions/sd-webui-additional-networks

# copy also configs here

# ADD https://huggingface.co/ckpt/sd15/resolve/main/v1-5-pruned-emaonly.ckpt /workspace/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.ckpt
# add also other models here

RUN adduser --disabled-password --gecos '' poduser
RUN chown -R poduser:poduser /workspace
RUN chmod -R 777 /workspace
USER poduser

CMD [ "/start.sh" ]

