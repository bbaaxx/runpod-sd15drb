import os

print('Launching  setup: Launching...')
launch_string = "./webui.sh -f --skip-cuda-check"
os.system(launch_string)
print('Setup procedure complete')

