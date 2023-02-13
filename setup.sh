!#/bin/bash
echo "Starting Pod Setup"

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

# Set permissions
chown -R poduser:poduser /workspace
chown -R poduser:poduser /sdui
chown poduser:poduser /start.sh
chmod +x /start.sh

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

echo "Pod Setup Complete"


