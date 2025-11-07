#!/bin/bash
#SBATCH --job-name=wan-t2v
#SBATCH --partition=gpua100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=00:20:00
#SBATCH --output=./logs/%x-%j.log

set -euo pipefail
trap 'echo "❌ Error in line $LINENO: $BASH_COMMAND" >&2' ERR

### -------- CLI ARGUMENTS --------
PROMPT=""
PROMPT_FILE=""
SIZE="1280*704"
STEPS="60"
GUIDE_SCALE="7.5"
NAME=""
T5_CPU="false"
OFFLOAD_MODEL="true"
CKPT_DIR="./models/Wan2.2-TI2V-5B"
TASK="ti2v-5B"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt)
      shift; PROMPT="${1:-}"; shift || true ;;
    --prompt-file)
      shift; PROMPT_FILE="${1:-}"; shift || true ;;
    --size)
      shift; SIZE="${1:-}"; shift || true ;;
    --sample-steps|--steps)
      shift; STEPS="${1:-}"; shift || true ;;
    --guide-scale)
      shift; GUIDE_SCALE="${1:-}"; shift || true ;;
    --name)
      shift; NAME="${1:-}"; shift || true ;;
    --t5-cpu)
      T5_CPU="true"; shift ;;
    --no-offload)
      OFFLOAD_MODEL="false"; shift ;;
    --ckpt-dir)
      shift; CKPT_DIR="${1:-}"; shift || true ;;
    --task)
      shift; TASK="${1:-}"; shift || true ;;
    -h|--help)
      echo "Usage: sbatch $0 [--prompt \"text\" | --prompt-file file.txt] [--name filename] [--size WxH] [--sample-steps N] [--guide-scale F]"
      echo "       Optional: --save-file PATH --t5-cpu --no-offload --ckpt-dir PATH --task ti2v-5B"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

# Resolve prompt from file if provided
if [[ -n "$PROMPT_FILE" ]]; then
  if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "❌ Prompt file not found: $PROMPT_FILE" >&2
    exit 1
  fi
  PROMPT="$(cat "$PROMPT_FILE")"
fi

if [[ -z "$PROMPT" ]]; then
  echo "❌ No prompt provided. Use --prompt \"...\" or --prompt-file path.txt" >&2
  exit 1
fi

# Determine output filename
if [[ -n "$NAME" ]]; then
  SAVE_FILE="./outputs/${NAME}.mp4"
else
  SAVE_FILE="./outputs/t2v-$(date +%Y%m%d-%H%M%S).mp4"
fi

### -------- ENV SETUP --------
module purge
module load palma/2022a
module load GCCcore/11.3.0
module load Python/3.10.4
module load palma/2023a
module load CUDA/12.1.1

source .venv/bin/activate

### -------- INFO --------
echo "▶ Task:            $TASK"
echo "▶ Size:            $SIZE"
echo "▶ Steps:           $STEPS"
echo "▶ Guide scale:     $GUIDE_SCALE"
echo "▶ Offload model:   $OFFLOAD_MODEL"
echo "▶ T5 on CPU:       $T5_CPU"
echo "▶ Checkpoints dir: $CKPT_DIR"
echo "▶ Save file:       $SAVE_FILE"
echo "▶ Prompt length:   ${#PROMPT} chars"

### -------- RUN --------
PY_ARGS=(
  ./wan2.2/generate.py
  --task "$TASK"
  --size "$SIZE"
  --sample_guide_scale "$GUIDE_SCALE"
  --sample_steps "$STEPS"
  --ckpt_dir "$CKPT_DIR"
  --prompt "$PROMPT"
  --save_file "$SAVE_FILE"
  --convert_model_dtype
)

# Optional flags
[[ "$OFFLOAD_MODEL" == "true" ]] && PY_ARGS+=( --offload_model True )
[[ "$T5_CPU" == "true" ]] && PY_ARGS+=( --t5_cpu )

python "${PY_ARGS[@]}"

echo "✅ Done. Saved to: $SAVE_FILE"