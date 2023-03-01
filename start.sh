#!/bin/bash
echo "pod started"
export PYTHONUNBUFFERED=1
export GPG_TTY=$(tty)
# su poduser -

if [[ $PUBLIC_KEY ]]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >>authorized_keys
    chmod 700 -R ~/.ssh
    cd /
fi

if [[ $JUPYTER_PASSWORD ]]; then
    cd /
    source /workspace/stable-diffusion-webui/venv/bin/activate
    jupyter nbextension enable --py widgetsnbextension
    nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace &
    echo "Jupyter Lab Started"
    deactivate
fi

if [[ $WITH_TENSORBOARD ]]; then
    cd /workspace
    mkdir -p /workspace/logs/ti
    mkdir -p /workspace/logs/dreambooth
    ln -s /workspace/stable-diffusion-webui/models/dreambooth /workspace/logs/dreambooth
    ln -s /workspace/stable-diffusion-webui/textual_inversion /workspace/logs/ti
    source /workspace/stable-diffusion-webui/venv/bin/activate
    nohup tensorboard --logdir=/workspace/logs --port=6006 --host=
    echo "Tensorboard Started"
    deactivate
fi

if [ ! -f /sdui/switch.off ]; then
    if [ ! -f /workspace/local_ckpts/v1-5-pruned-emaonly.safetensors ]; then
        echo "Checkpoint folder not found, creating"
        mkdir -p /workspace/local_ckpts
        ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion/
        echo "Downloading checkpoint"
        wget --show-progress -P /workspace/local_ckpts https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
    fi
    echo "Switch-off flag not found Launching WebUI"

    if [[ $WEBUI == "invoke" ]]; then
        echo "launching InvokeAi"
        source /workspace/invoke/.venv/bin/activate
        python /workspace/invoke/relauncher.py &
        deactivate
    elif [[ $WEBUI == "a1111" ]]; then
        echo "Launching A1111 webui"
        cd /workspace/stable-diffusion-webui
        source ./venv/bin/activate
        python relauncher.py &
        deactivate
    fi
fi

sleep infinity
