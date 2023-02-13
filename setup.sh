!#/bin/bash
echo "pod started"

# Install packages
apt-get update --yes && apt-get upgrade --yes  \
    # tools for minimized images
    tzdata net-tools vim man file sudo \
    # basic tools
    wget curl git git-lfs tmux gpg zsh openssh-server \
    # python tools
    libgl1 libglib2.0-0 python3-pip python-is-python3 python3-venv
apt-get clean && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install JupyterLab as Root
pip install --upgrade pip && \
pip install jupyterlab && \
pip install ipywidgets


# Create directories
mkdir -p /workspace/local_ckpts # Mount point for checkpoints (on transient storage)
ln -s /sdui/invoke /workspace
ln -s /sdui/stable-diffusion-webui /workspace 

# Create a user
useradd -m  -s /bin/zsh poduser
usermod -aG sudo poduser && echo "poduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/poduser
chmod 044 /etc/sudoers.d/poduser

# Provide user access to the directories
chown -R poduser:poduser /workspace
chown -R poduser:poduser /sdui

# chmod -R 777 /sdui
# chmod -R 777 /workspace

