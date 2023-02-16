!#/bin/bash
echo "Starting Apps Setup"

# Create directories
mkdir -p /workspace/local_ckpts # Mount point for checkpoints (on transient storage)
mkdir -p /sdui/outputs          # Mount point for outputs (on persistent storage)

# Install JupyterLab as the user poduser
# su - poduser -c "bash /user_apps.sh"
cd /workspace
python -m venv /workspace/jupyter/.venv --prompt JupyterLab
source /workspace/jupyter/.venv/bin/activate
pip install --upgrade pip
pip install jupyterlab
pip install ipywidgets
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/toc
jupyter labextension install @jupyterlab/git
jupyter serverextension enable --py jupyterlab_git
jupyter labextension install @jupyterlab/xkcd-extension
deactivate

# Install InvokeAI
mkdir -p /sdui/invoke
cd /sdui/invoke
python -m venv .venv --prompt InvokeAI
source .venv/bin/activate
pip install InvokeAI[xformers] --use-pep517 --extra-index-url https://download.pytorch.org/whl/cu117
deactivate

# Install WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /sdui/stable-diffusion-webui
## Install webui dependencies
cd /sdui/stable-diffusion-webui
python -m venv venv --prompt WebUi
source venv/bin/activate
pip install -r requirements.txt
## Install extensions
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-promptgen.git /sdui/stable-diffusion-webui/extensions/stable-diffusion-webui-promptgen
git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git /sdui/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser
git clone https://github.com/camenduru/sd-civitai-browser.git /sdui/stable-diffusion-webui/extensions/sd-civitai_browser
git clone https://github.com/camenduru/stable-diffusion-webui-huggingface.git /sdui/stable-diffusion-webui/extensions/stable-diffusion-webui-huggingface
git clone https://github.com/deforum-art/deforum-for-automatic1111-webui.git /sdui/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui
git clone https://github.com/camenduru/sd-webui-additional-networks.git /sdui/stable-diffusion-webui/extensions/sd-webui-additional-networks
### Install dreambooth extension
git clone https://github.com/d8ahazard/sd_dreambooth_extension.git /sdui/stable-diffusion-webui/extensions/sd_dreambooth_extension
pip install -r /sdui/stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt
deactivate

# make symbolic links
ln -s /sdui/invoke /workspace
ln -s /sdui/stable-diffusion-webui /workspace
ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion/
ln -s /workspace/local_ckpts /workspace/invoke/models/InvokeAI/
ln -s /workspace/stable-diffusion-webui/outputs /sdui/outputs/webui
ln -s /workspace/invoke/outputs /sdui/outputs/invoke

# Set permissions
# chown -R poduser:poduser /workspace
# chown -R poduser:poduser /sdui
# chown poduser:poduser /start.sh

// Enable write on created directories
chmod -R 777 /workspace
chmod -R 777 /sdui

echo "Apps Setup Complete"
