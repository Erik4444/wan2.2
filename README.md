# WAN repository

This repository contains a small project scaffold and helper scripts. This README explains how to download a model (prefetch/snapshot), create and activate a Python virtual environment, and install required packages.

## Quick overview

- Repository root: `wan2.2`
- Example script: `run-t2v.sh`

## Install

1. Clone the repository:

```bash
git clone <repo-url>
cd wan2.2
```

2. Create and activate a virtual environment (recommended):

```bash
python -m venv .venv
source .venv/bin/activate
```

3. Install Python requirements:

```bash
pip install -r requirements.txt
```

## Download the model

Option A — Hugging Face CLI (login + repo download)

1. Install the CLI and log in (this stores your credentials locally):

```bash
pip install huggingface-hub
huggingface-cli login
```

2. Download the model repository. Two common methods:

- Use `git` to clone the model repo (recommended if you already have `git-lfs` set up):

```bash
# Make a folder for models
mkdir -p models
cd models
# Clone the model repository (requires git-lfs for large files)
git clone https://huggingface.co/Wan-AI/Wan2.2-TI2V-5B
```

- Or use the HF CLI repo helpers (if available in your huggingface-hub version):

```bash
# some hf hub versions support a repo clone helper
huggingface-cli repo clone Wan-AI/Wan2.2-TI2V-5B models/Wan2.2-TI2V-5B
```

Notes about Git LFS and large files:
- Many model repositories store large binary files via Git LFS. Install Git LFS before cloning large models:

```bash
brew install git-lfs
git lfs install
```

- If you can't use Git LFS or cloning fails, use the Python `snapshot_download` method in Option B below.

Option B — Python: `huggingface_hub.snapshot_download` (reliable, supports tokens)

```bash
python - <<'PY'
from huggingface_hub import snapshot_download

MODEL_ID = "<MODEL_ID>"  # e.g. "Wan-AI/Wan2.2-TI2V-5B"
# If the model is private, first run `huggingface-cli login` (above), or set HF_TOKEN environment variable.
path = snapshot_download(repo_id=MODEL_ID, cache_dir="./models")
print("Model snapshot downloaded to:", path)
PY
```

After downloading

- Place or point your scripts to the downloaded model path (for example `models/<MODEL_ID>`).

## Wan2.2 repository and running the generator

This project expects a separate repo (Wan2.2) that contains the code to generate videos (the `generate.py` script). The `run-t2v.sh` script in this repository calls into Wan2.2's generator to produce videos.

1. Clone Wan2.2 next to this repository (or into a subdirectory). Example placing it in `wan2.2` inside this repo:

```bash
# from the repository root
git clone https://github.com/Wan-Video/Wan2.2.git wan2.2
```

2. Install Wan2.2's Python requirements (assumes it has a `requirements.txt`):

```bash
source .venv/bin/activate
pip install -r wan2.2/requirements.txt
```

3. Confirm the model path and configuration inside `wan2.2` or `run-t2v.sh`:

- `run-t2v.sh` expects `generate.py` inside the Wan2.2 repo and will call it to render/generate videos. Open `run-t2v.sh` and update any MODEL_PATH or REPO_DIR variables to point to the downloaded model (for example `models/<MODEL_ID>`) and the Wan2.2 directory.

4. Run the wrapper script to generate videos:

```bash
sbatch run-t2v.sh
```

---
