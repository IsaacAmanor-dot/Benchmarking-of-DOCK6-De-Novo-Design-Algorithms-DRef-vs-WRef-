#!/bin/bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
source ./000.config.sh

RESULTS="${WREF_DIR}/zzz.results"
INPUT="${WREF_DIR}/zzz.scripts/rescore_with_hms.in"
COMPLETED="${RESULTS}/WRef_OFF.completed.denovo_build.mol2"

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
    -o "${RESULTS}/WRef_OFF.rescore_hms.out"

echo "WRef HMS rescoring completed."
echo "Results: $RESULTS"
