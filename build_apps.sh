!#/bin/bash
echo "Starting To Build Dependencies"

# Install packages
apt-get update --yes && apt-get upgrade --yes && \ 
apt-get install --yes wget curl git libgl1 libglib2.0-0 python3-pip python-is-python3 python3-venv
apt-get clean && rm -rf /var/lib/apt/lists/* && echo "en_US.UTF-8 UTF-8" >/etc/locale.gen

# Create Mount point (on persistent storage)
mkdir -p /sdui

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

# chmod -R 777 /sdui

echo "Dependencies Built and Installed"
