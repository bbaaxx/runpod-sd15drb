
# ARG BASE_IMAGE=tensorflow/tensorflow:latest-gpu
ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

FROM ${BASE_IMAGE} as build-base
ADD build_apps.sh /
RUN chmod +x /build_apps.sh && /build_apps.sh

FROM ${BASE_IMAGE} as run-base

RUN useradd -m -s /bin/bash poduser && usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/poduser && chmod 044 /etc/sudoers.d/poduser
COPY --from=build-base --chown=poduser:poduser /sdui /
ADD webui-user.template /sdui/stable-diffusion-webui/webui-user.sh
ADD relauncher-webui.py /sdui/stable-diffusion-webui/relauncher.py
ADD relauncher-invoke.py /sdui/invoke/relauncher.py
ADD start.sh /
ADD setup.sh /
RUN mkdir -p /workspace/local_ckpts && chown -R poduser:poduser /workspace && chown -R poduser:poduser /sdui && chmod +x /start.sh && chown poduser:poduser /start.sh
RUN chmod +x /setup.sh

WORKDIR /sdui
USER poduser
RUN /setup.sh

CMD [ "/start.sh" ]