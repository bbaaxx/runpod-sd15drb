import os

print('Launching  setup: Launching...')
launch_string = "/workspace/stable-diffusion-webui/webui.sh --skip-cuda-check --xformers"
os.system(launch_string)
print('Setup procedure complete')

