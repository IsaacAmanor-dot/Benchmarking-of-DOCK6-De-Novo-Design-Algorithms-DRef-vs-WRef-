#!/bin/bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
source ./000.config.sh

for file in \
    "$DOCK_BIN" \
    "$SCAFFOLD" "$LINKER" "$SIDECHAIN" "$TORENV" \
    "$REFERENCE" "$SPHERES" \
    "${GRID_PREFIX}.bmp" "${GRID_PREFIX}.nrg" \
    "$VDW_FILE" "$FLEX_FILE" "$FLEX_DRIVE" \
    "$DN_TEMPLATE" "$HMS_TEMPLATE"
do
    [[ -f "$file" ]] || {
        echo "Missing file: $file" >&2
        exit 1
    }
done

[[ -x "$DOCK_BIN" ]] || {
    echo "DOCK executable is not executable: $DOCK_BIN" >&2
    exit 1
}

python3 << 'PY'
import os
from pathlib import Path

def env(key):
    return os.environ[key]

def make_input(template, output, changes):
    lines = Path(template).read_text().splitlines()
    seen = {key: 0 for key in changes}
    updated = []

    for line in lines:
        parts = line.split()

        if parts and parts[0] in changes:
            key = parts[0]
            seen[key] += 1
            line = f"{key:<60} {changes[key]}"

        updated.append(line)

    bad = [key for key, count in seen.items() if count != 1]
    if bad:
        raise RuntimeError(
            f"Missing or repeated parameters in {template}: {bad}"
        )

    Path(output).write_text("\n".join(updated) + "\n")

for mode, directory, prefix, dynamic in [
    ("DRef", env("DREF_DIR"), "DRef_ON", "yes"),
    ("WRef", env("WREF_DIR"), "WRef_OFF", "no"),
]:
    base = Path(directory)
    scripts = base / "zzz.scripts"
    results = base / "zzz.results"

    growth = {
        "dn_fraglib_scaffold_file": env("SCAFFOLD"),
        "dn_fraglib_linker_file": env("LINKER"),
        "dn_fraglib_sidechain_file": env("SIDECHAIN"),
        "dn_torenv_table": env("TORENV"),
        "dn_user_specified_anchor": "no",
        "dn_unique_anchors": env("N_ANCHORS"),
        "dn_max_grow_layers": env("N_LAYERS"),
        "dn_max_root_size": env("MAX_ROOT_SIZE"),
        "dn_max_layer_size": env("MAX_LAYER_SIZE"),
        "dn_write_growth_trees": "yes",
        "dn_write_final_layer_growth_trees": "yes",
        "dn_output_prefix": prefix,
        "receptor_site_file": env("SPHERES"),
        "descriptor_use_dynamic_reference": dynamic,
        "descriptor_use_grid_score": "yes",
        "descriptor_use_hungarian": "yes",
        "descriptor_grid_score_grid_prefix": env("GRID_PREFIX"),
        "descriptor_hms_score_ref_filename": env("REFERENCE"),
        "descriptor_hms_score_matching_coeff": env("GROW_HMS_MATCH"),
        "descriptor_hms_score_rmsd_coeff": env("GROW_HMS_RMSD"),
        "descriptor_weight_grid_score": env("GROW_GRID_WEIGHT"),
        "descriptor_weight_hms_score": env("GROW_HMS_WEIGHT"),
        "vdw_defn_file": env("VDW_FILE"),
        "flex_defn_file": env("FLEX_FILE"),
        "flex_drive_file": env("FLEX_DRIVE"),
    }

    rescoring = {
        "ligand_atom_file":
            str(results / f"{prefix}.completed.denovo_build.mol2"),
        "descriptor_use_dynamic_reference": "no",
        "descriptor_use_grid_score": "no",
        "descriptor_use_hungarian": "yes",
        "descriptor_hms_score_ref_filename": env("REFERENCE"),
        "descriptor_hms_score_matching_coeff": env("RESCORE_HMS_MATCH"),
        "descriptor_hms_score_rmsd_coeff": env("RESCORE_HMS_RMSD"),
        "descriptor_weight_hms_score": "1",
        "minimize_ligand": "no",
        "ligand_outfile_prefix": f"Rescored_{prefix}",
        "rank_ligands": "yes",
        "vdw_defn_file": env("VDW_FILE"),
        "flex_defn_file": env("FLEX_FILE"),
        "flex_drive_file": env("FLEX_DRIVE"),
    }

    make_input(
        env("DN_TEMPLATE"),
        scripts / "dn_generic.in",
        growth,
    )

    make_input(
        env("HMS_TEMPLATE"),
        scripts / "rescore_with_hms.in",
        rescoring,
    )

    print(f"{mode}: input files generated")

print("Done.")
PY
