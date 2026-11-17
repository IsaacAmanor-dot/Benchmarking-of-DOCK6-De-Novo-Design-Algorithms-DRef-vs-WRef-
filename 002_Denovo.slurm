#!/bin/bash
#SBATCH --job-name=2GQG_DRef_WRef
#SBATCH --partition=rn-long-40core
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-2
#SBATCH --time=4-00:00:00
#SBATCH --output=002_Denovo.%A_%a.out
#SBATCH --error=002_Denovo.%A_%a.err

set -euo pipefail

PROJECT_ROOT="${SLURM_SUBMIT_DIR:?SLURM_SUBMIT_DIR is not set}"

cd "$PROJECT_ROOT"
source ./000.config.sh

module purge
unset LD_LIBRARY_PATH
hash -r
module load gcc-stack

case "$SLURM_ARRAY_TASK_ID" in
    1)
        MODE="DRef"
        PREFIX="DRef_ON"
        EXP_DIR="$DREF_DIR"
        ;;
    2)
        MODE="WRef"
        PREFIX="WRef_OFF"
        EXP_DIR="$WREF_DIR"
        ;;
    *)
        echo "Invalid array task ID: $SLURM_ARRAY_TASK_ID" >&2
        exit 1
        ;;
esac

INPUT="${EXP_DIR}/zzz.scripts/dn_generic.in"
RESULTS="${EXP_DIR}/zzz.results"
COMPLETED="${RESULTS}/${PREFIX}.completed.denovo_build.mol2"
LOG="${RESULTS}/${PREFIX}.denovo.out"

[[ -f "$INPUT" ]] || {
    echo "Missing DOCK input: $INPUT" >&2
    exit 1
}

[[ ! -e "$COMPLETED" ]] || {
    echo "Existing completed MOL2: $COMPLETED" >&2
    exit 1
}

cd "$RESULTS"

echo "Running $MODE"
echo "Node: $(hostname)"
echo "Input: $INPUT"

"$DOCK_BIN" -i "$INPUT" -o "$LOG"

echo "$MODE completed successfully."
