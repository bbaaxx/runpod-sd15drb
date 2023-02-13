
# ARG BASE_IMAGE=tensorflow/tensorflow:latest-gpu
ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-poduser22.04

FROM ${BASE_IMAGE} as build-base
ADD build_apps.sd /
RUN chmod +x /build_apps.sh && /build_apps.sh

FROM ${BASE_IMAGE} as dev-base
COPY --from=build-base /sdui /sdui
ADD webui-user.template /sdui/stable-diffusion-webui/webui-user.sh
ADD relauncher-webui.py /sdui/stable-diffusion-webui/relauncher.py
ADD relauncher-invoke.py /sdui/invoke/relauncher.py
ADD setup.sh /
RUN chmod +x /setup.sh && /setup.sh

ADD start.sh /
RUN chmod +x /start.sh && chown poduser:poduser /start.sh && chown poduser:poduser /sdui/stable-diffusion-webui/webui-user.sh && chown poduser:poduser /sdui/stable-diffusion-webui/relauncher.py

WORKDIR /sdui
USER poduser

CMD [ "/start.sh" ]