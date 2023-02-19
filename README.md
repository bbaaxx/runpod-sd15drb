# Template to buld a Docker container with a Stable Difussion webui work environment to work on Runpod.io and elsewhere
## What's in the box?
- Nvidia CUDA 11.7 devel image on Ubuntu 22.04 (minified but with some base tools added)
- Switch between A111 webui and InvokeAI (WIP)
- Dreamboot, Inspiration and other useful (opinionated) extensions for model training and evaluating results

## How to use
On runpod look for this template on the comunity templates area here.

Elsewhere, edit 'start.sh' and the included templates to fit your needs and probably configure your container to launch `/start.sh` on startup.