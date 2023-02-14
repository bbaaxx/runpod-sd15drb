
# ARG BASE_IMAGE=tensorflow/tensorflow:latest-gpu
ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

FROM ${BASE_IMAGE} as build-base
ADD build_apps.sh /
RUN chmod +x /build_apps.sh && /build_apps.sh

FROM ${BASE_IMAGE} as run-container
RUN apt-get update --yes && apt-get upgrade --yes  &&  apt-get install --yes \
    net-tools vim man file sudo unzip \
    wget curl git git-lfs tmux gpg zsh openssh-server \
    libgl1 libglib2.0-0 python3-pip python-is-python3 python3-venv && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN useradd -m -s /bin/bash poduser && usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/poduser && chmod 044 /etc/sudoers.d/poduser

COPY --from=build-base --chown=poduser:poduser /sdui /sdui

ADD webui-user.template /sdui/stable-diffusion-webui/webui-user.sh
ADD relauncher-webui.py /sdui/stable-diffusion-webui/relauncher.py
ADD relauncher-invoke.py /sdui/invoke/relauncher.py
ADD start.sh /
ADD setup.sh /
RUN chmod +x /start.sh && chmod +x /setup.sh && /setup.sh 

WORKDIR /sdui
USER poduser

CMD [ "/start.sh" ]