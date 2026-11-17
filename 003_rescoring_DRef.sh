#!/bin/bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
source ./000.config.sh

RESULTS="${DREF_DIR}/zzz.results"
INPUT="${DREF_DIR}/zzz.scripts/rescore_with_hms.in"
COMPLETED="${RESULTS}/DRef_ON.completed.denovo_build.mol2"

[[ -s "$COMPLETED" ]] || {
    echo "Missing completed molecules: $COMPLETED" >&2
    exit 1
}

[[ -f "$INPUT" ]] || {
    echo "Missing rescoring input: $INPUT" >&2
    exit 1
}

cd "$RESULTS"

"$DOCK_BIN" \
    -i "$INPUT" \
    -o "${RESULTS}/DRef_ON.rescore_hms.out"

echo "DRef HMS rescoring completed."
echo "Results: $RESULTS"
