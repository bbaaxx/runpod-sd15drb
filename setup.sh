!#/bin/bash
echo "Starting Pod Apps Setup"

# Create directories
mkdir -p /workspace/local_ckpts # Mount point for checkpoints (on transient storage)
mkdir -p /sdui/outputs          # Mount point for outputs (on persistent storage)

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
chmod +x /start.sh

// Enable write on created directories
chmod -R 777 /workspace
chmod -R 777 /sdui

# Install JupyterLab as the user poduser
# su - poduser -c "bash /user_apps.sh"
bash ./user_apps.sh
echo "Pod Apps Setup Complete"
