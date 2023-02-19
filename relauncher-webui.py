import os, time

n = 0
gradio_auth = os.getenv('GRADIO_AUTH')
while True:
    print('Relauncher: Launching...')
    if n > 0:
        print(f'\tRelaunch count: {n}')
    launch_string = "./webui.sh -f"
    if gradio_auth:
        launch_string += " --gradio-auth " + gradio_auth
    os.system(launch_string)
    print('Relauncher: Process is ending. Relaunching in 2s...')
    n += 1
    time.sleep(2)