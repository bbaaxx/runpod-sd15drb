# Template to buld a Docker container with a Stable Difussion webui work environment for training/refining models
Designed to work on Runpod.io but it should run elsewhere with little-to-none customization.

## What's in the box?
- Nvidia CUDA 11.7 devel image on Ubuntu 22.04 (minified but with some base tools added)
- Switch between A111 webui and InvokeAI (WIP)
- Dreamboot, Inspiration and other useful (opinionated) extensions for model training and evaluating results

## How to use
On runpod look for this template on the comunity [templates area here](https://www.runpod.io/console/templates).

Elsewhere, edit 'start.sh' and/or the included scripts to fit your needs and probably configure your container to run `/start.sh` on launch.

## Like what you see?
 am a developer, artist and crazy inventor. If something I created is useful for you, please consider [buying me a coffee to help me keep creating](https://www.buymeacoffee.com/bbaaxx). Thanks!

## License
[DON'T BE A DICK PUBLIC LICENSE](https://dbad-license.org/)

> Version 1.1, December 2016

> Copyright (C) [2023] [Ed Mosqueda (@bbaaxx)]

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document.

> DON'T BE A DICK PUBLIC LICENSE
> TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

1. Do whatever you like with the original work, just don't be a dick.

   Being a dick includes - but is not limited to - the following instances:

 1a. Outright copyright infringement - Don't just copy this and change the name.
 1b. Selling the unmodified original with no work done what-so-ever, that's REALLY being a dick.
 1c. Modifying the original work to contain hidden harmful content. That would make you a PROPER dick.

2. If you become rich through modifications, related works/services, or supporting the original work,
share the love. Only a dick would make loads off this work and not buy the original work's
creator(s) a pint.

3. Code is provided with no warranty. Using somebody else's code and bitching when it goes wrong makes
you a DONKEY dick. Fix the problem yourself. A non-dick would submit the fix back.

