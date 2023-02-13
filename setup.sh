!#/bin/bash
echo "pod started"

# Install packages
sudo apt-get update --yes && apt-get upgrade --yes  &&  apt-get install --yes \
    net-tools vim man file sudo \
    wget curl git git-lfs tmux gpg zsh openssh-server \
    libgl1 libglib2.0-0 python3-pip python-is-python3 python3-venv
    
sudo apt-get clean && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen




# Create directories
mkdir -p /workspace/local_ckpts # Mount point for checkpoints (on transient storage)
mkdir -p /sdui/outputs # Mount point for outputs (on persistent storage)

# make symbolic links
ln -s /sdui/invoke /workspace
ln -s /sdui/stable-diffusion-webui /workspace
ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion/
ln -s /workspace/local_ckpts /workspace/invoke/models/InvokeAI/
ln -s /workspace/stable-diffusion-webui/outputs /sdui/outputs/webui
ln -s /workspace/invoke/outputs /sdui/outputs/invoke

# Install JupyterLab as the user poduser
su - poduser -c "cd /home/poduser && \
    python -m venv /workspace/jupyter/.venv --prompt JupyterLab && \
    source /workspace/jupyter/.venv/bin/activate && \
    pip install --upgrade pip && \
    pip install jupyterlab && \
    pip install ipywidgets && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install @jupyterlab/git && \
    jupyter serverextension enable --py jupyterlab_git && \
    jupyter labextension install @jupyterlab/xkcd-extension && \
    deactivate"




