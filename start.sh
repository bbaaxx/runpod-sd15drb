#!/bin/bash
echo "pod started"
export PYTHONUNBUFFERED=1
export GPG_TTY=$(tty)

if [ $PUBLIC_KEY ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >>authorized_keys
    chmod 700 -R ~/.ssh
    cd /
fi

if [ $JUPYTER_PASSWORD ]; then
    cd /
    source /workspace/venv/bin/activate
    jupyter nbextension enable --py widgetsnbextension
    nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace &
    echo "Jupyter Lab Started"
    deactivate
fi

if [ $WITH_TENSORBOARD ]; then
    cd /workspace
    mkdir -p /workspace/logs/ti
    mkdir -p /workspace/logs/dreambooth
    ln -s /workspace/stable-diffusion-webui/models/dreambooth /workspace/logs/dreambooth
    ln -s /workspace/stable-diffusion-webui/textual_inversion /workspace/logs/ti
    source /workspace/venv/bin/activate
    nohup tensorboard --logdir=/workspace/logs --port=6006 --host=0.0.0.0 &
    echo "Tensorboard Started"
    deactivate
fi

if [ $DOWNLOAD_CKPT_URL ]; then
    echo "Checkpoint folder not found, creating"
    mkdir -p /workspace/shared/checkpoints
    wget --show-progress -P /workspace/shared/checkpoints $DOWNLOAD_CKPT_URL
fi

if [ $AUTOLAUNCH ]; then
    echo "Switch-off flag not found Launching WebUI"
    echo "Launching A1111 webui"
    source /workspace/stable-diffusion-webui/venv/bin/activate
    cd /workspace/stable-diffusion-webui
    python relauncher.py &
    deactivate
fi

sleep infinity
