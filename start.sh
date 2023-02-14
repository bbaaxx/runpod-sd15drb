#!/bin/bash
echo "pod started"
export PYTHONUNBUFFERED=1
export GPG_TTY=$(tty)

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
    source /workspace/jupyter/.venv/bin/activate
    jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
    echo "Jupyter Lab Started"
    deactivate
fi

if [ ! -f /sdui/switch.off ]; then
    if [ ! -d /workspace/local_ckpts ]; then
        echo "Checkpoint folder not found, creating"
        mkdir -p /workspace/local_ckpts
        ln -s /workspace/local_ckpts /workspace/stable-diffusion-webui/models/Stable-diffusion/
        echo "Downloading checkpoint"
        wget --show-progress -P /workspace/local_ckpts https://huggingface.co/ckpt/sd15/resolve/main/v1-5-pruned-emaonly.ckpt
    fi
    echo "Switch-off flag not found Launching WebUI"

    if [[ $WEBUI == "invoke" ]]; then
        echo "launching InvokeAi"
        source /sdui/invoke/.venv/bin/activate
        python relauncher.py &
    elif [[ $WEBUI == "a111" ]]; then
        echo "Launching A111 webui"
        source /sdui/stable-diffusion-webui/venv/bin/activate
        cd /sdui/stable-diffusion-webui
        python relauncher.py &
    fi
fi

sleep infinity
