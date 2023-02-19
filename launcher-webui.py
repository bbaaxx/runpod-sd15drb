import os

print('Launching  setup: Launching...')
launch_string = "/workspace/stable-diffusion-webui/launch.sh --skip-cuda-check"
os.system(launch_string)
print('Setup procedure complete')

