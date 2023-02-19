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
    source /workspace/jupyter/.venv/bin/activate
    jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
    echo "Jupyter Lab Started"
    deactivate
fi

if [ ! -f /sdui/switch.off ]; then
    if [ ! -f /workspace/local_ckpts/v1-5-pruned-emaonly.ckpt ]; then
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
        python /sdui/invoke/relauncher.py &
    elif [[ $WEBUI == "a1111" ]]; then
        echo "Launching A1111 webui"
        # source /sdui/stable-diffusion-webui/venv/bin/activate
        python /sdui/stable-diffusion-webui/launcher.py &
    fi
fi

sleep infinity
