# 2GQG DRef vs WRef Experiment

Compare Dynamic Referencing (DRef) and fixed-reference
de novo growth (WRef) in DOCK6.14 using the 2GQG focused
fragment library.

Both methods use nine automatically selected anchors,
nine growth layers, identical sampling parameters,
and the same Grid + HMS scoring configuration.

DRef uses dynamic partial references; WRef uses the
fixed reference. Both write standard and optional
final-layer growth trees.

Completed molecules are independently rescored against
the full 2GQG ligand using HMS.

## Scripts

- 000.config.sh: Paths and experiment parameters
- 001.write_scripts.sh: Generate DOCK input files
- 002_Denovo.slurm: Run DRef and WRef on separate nodes
- 003_rescoring_DRef.sh: Rescore DRef molecules
- 004_rescoring_WRef.sh: Rescore WRef molecules

## Run

From the project root:

    bash 001.write_scripts.sh
    sbatch 002_Denovo.slurm

After de novo completion:

    bash 003_rescoring_DRef.sh
    bash 004_rescoring_WRef.sh

## Outputs

Each experiment stores generated inputs in zzz.scripts
and molecular results, growth trees, and logs in zzz.results.

The DRef and WRef rescoring inputs use identical HMS
parameters and the same full-reference ligand.

The experiment requires the developmental DOCK6.14
executable with final-layer growth-tree support.
