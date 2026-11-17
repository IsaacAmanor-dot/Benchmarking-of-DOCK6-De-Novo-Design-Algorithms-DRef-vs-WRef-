#!/bin/bash
set -euo pipefail

export ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

export DOCK_ROOT="${DOCK_ROOT:-/gpfs/projects/rizzo/iamanor/Collaborations/Carissa/001_DRef_6.14_version/dock6_dev}"
export DOCK_BIN="${DOCK_BIN:-${DOCK_ROOT}/bin/dock6}"
export PARAM_ROOT="${PARAM_ROOT:-${DOCK_ROOT}/parameters}"

export FRAG_ROOT="${FRAG_ROOT:-/gpfs/projects/rizzo/iamanor/Collaborations/Carissa/2GQG_Fragment_Library}"
export SYS_ROOT="${SYS_ROOT:-/gpfs/projects/rizzo/iamanor/Systems_and_Library_Files/001_Systems_Files/002_DRef_Systems/2GQG}"

export SCAFFOLD="${FRAG_ROOT}/2GQG_lig_fraglib_scaffold.mol2"
export LINKER="${FRAG_ROOT}/2GQG_lig_fraglib_linker.mol2"
export SIDECHAIN="${FRAG_ROOT}/2GQG_lig_fraglib_sidechain.mol2"
export TORENV="${FRAG_ROOT}/2GQG_combined_fraglib_torsion.dat"

export REFERENCE="${SYS_ROOT}/2GQG.lig.am1bcc.mol2"
export SPHERES="${SYS_ROOT}/2GQG.rec.clust.close.sph"
export GRID_PREFIX="${SYS_ROOT}/2GQG.rec"

export VDW_FILE="${PARAM_ROOT}/vdw_de_novo.defn"
export FLEX_FILE="${PARAM_ROOT}/flex.defn"
export FLEX_DRIVE="${PARAM_ROOT}/flex_drive.tbl"

export TEMPLATE_ROOT="${ROOT}/zzz.templates"
export DN_TEMPLATE="${TEMPLATE_ROOT}/dn_generic.in"
export HMS_TEMPLATE="${TEMPLATE_ROOT}/rescore_with_hms.in"

export N_ANCHORS=9
export N_LAYERS=9
export MAX_ROOT_SIZE=25
export MAX_LAYER_SIZE=25

export MW_CUTOFF_TYPE="hard"
export MW_UPPER=500
export MW_LOWER=0.0
export FORMAL_CHARGE=1
export ROTATABLE_BONDS=10

export GROW_HMS_MATCH=-5
export GROW_HMS_RMSD=10
export GROW_GRID_WEIGHT=1
export GROW_HMS_WEIGHT=10

export RESCORE_HMS_MATCH=-5
export RESCORE_HMS_RMSD=1

export PARTITION="rn-long-40core"
export WALLTIME="4-00:00:00"

export DREF_DIR="${ROOT}/001_DRef_2GQG"
export WREF_DIR="${ROOT}/002_WRef_2GQG"

for dir in "$DREF_DIR" "$WREF_DIR"; do
    mkdir -p "${dir}/zzz.scripts"
    mkdir -p "${dir}/zzz.results"
done
