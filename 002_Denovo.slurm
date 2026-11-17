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

# Submit from the original script; Slurm runs a spooled copy.
if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
    SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    source "${SCRIPT_ROOT}/000.config.sh"
    exec sbatch --chdir="$ROOT" --partition="$PARTITION" --time="$WALLTIME" \
        "$ROOT/002_Denovo.slurm" "$ROOT"
fi

PROJECT_ROOT="${1:-${SLURM_SUBMIT_DIR:?Missing submission directory}}"
if [[ ! -f "${PROJECT_ROOT}/000.config.sh" ]]; then
    echo "Cannot locate 000.config.sh in: $PROJECT_ROOT" >&2
    echo "Submit with: bash /path/to/repository/002_Denovo.slurm" >&2
    exit 1
fi
source "${PROJECT_ROOT}/000.config.sh"

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
        echo "Invalid array task ID" >&2
        exit 1
        ;;
esac

INPUT="${EXP_DIR}/zzz.scripts/dn_generic.in"
RESULTS="${EXP_DIR}/zzz.results"
COMPLETED="${RESULTS}/${PREFIX}.completed.denovo_build.mol2"
LOG="${RESULTS}/${PREFIX}.denovo.out"

[[ -f "$INPUT" ]] || {
    echo "Missing input: $INPUT" >&2
    exit 1
}

[[ -x "$DOCK_BIN" ]] || {
    echo "DOCK executable unavailable: $DOCK_BIN" >&2
    exit 1
}

if [[ -e "$COMPLETED" ]]; then
    echo "Existing completed MOL2: $COMPLETED" >&2
    echo "Use a clean results directory for a new calculation." >&2
    exit 1
fi

cd "$RESULTS"

echo "Project: $ROOT"
echo "Calculation: $MODE"
echo "Node: $(hostname)"
echo "Results: $RESULTS"

"$DOCK_BIN" -i "$INPUT" -o "$LOG"

echo "$MODE completed successfully."
