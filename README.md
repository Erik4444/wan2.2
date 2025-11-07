# WAN repository

This repository contains a small project scaffold and helper scripts. This README explains how to download a model, create and activate a Python virtual environment, and install required packages.

## Quick overview

- Repository root: `wan`
- Example script: `run-t2v.sh`

## Install

1. Clone the repository:

```bash
git clone <repo-url> wan
cd wan
```

2. Create and activate a virtual environment (recommended):

```bash
python -m venv .venv
source .venv/bin/activate
```

3. Load modules:

Palma needs to be told which modules it should load so Python and CUDA is available.

```
module purge
module load palma/2022a
module load GCCcore/11.3.0
module load Python/3.10.4
module load palma/2023a
module load CUDA/12.1.1
```

4. Install Python requirements:

```bash
pip install -r requirements.txt
```

## Download the model
1. Install the CLI and log in (this stores your credentials locally):

```bash
pip install huggingface-hub
huggingface-cli login
```

2. Download the model repository:

```bash
huggingface-cli download Wan-AI/Wan2.2-TI2V-5B --local-dir ./Wan2.2-TI2V-5B
```

## Wan2.2 repository and running the generator

This project expects a separate repo (Wan2.2) that contains the code to generate videos (the `generate.py` script). The `run-t2v.sh` script in this repository calls into Wan2.2's generator to produce videos.

1. Clone Wan2.2 next to this repository (or into a subdirectory). Example placing it in `wan2.2` inside this repo:

```bash
# from the repository root
git clone https://github.com/Wan-Video/Wan2.2.git wan2.2
```

2. Install Wan2.2's Python requirements:

```bash
source .venv/bin/activate
pip install -r wan2.2/requirements.txt
```

3. Confirm the model path and configuration inside `wan2.2` or `run-t2v.sh`:

- `run-t2v.sh` expects `generate.py` inside the Wan2.2 repo and will call it to render/generate videos. Open `run-t2v.sh` and update any MODEL_PATH or REPO_DIR variables to point to the downloaded model and the Wan2.2 directory. It should work out of the box.

4. Run the wrapper script to generate videos:

```bash
sbatch run-t2v.sh --prompt <Your-prompt-here> --name <Your-name-here>
```

5. To watch the logs:

```
tail -f logs/wan-t2v-<jobID>.log
```
---
