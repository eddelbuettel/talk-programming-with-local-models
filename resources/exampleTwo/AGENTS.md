# AGENTS.md: Instructions for an RcppEigen update

Guidance for working in this repository. It summarizes the project, any known
quirks, and the workflow used to build/verify changes so sessions can pick up
context quickly. Adjust as needed.

## Project

Packages here uses package `RcppEigen`. With the newest development
version of `RcppEigen` they may experience a compilation error.

We want package bWGR (at version 2.2.18) to be able to work with both the
release RcppEigen 0.3.4.0.2 and the release candidate RcppEigen 0.4.9.9-5
reflecting Eigen 5.0.1

Some known issues:

- 'Eigen::all' is no longer available in Eigen 5.0.*, use
  'Eigen::indexing::all'
- 'Eigen::MappedSparseMatrix' is no longer available in Eigen 5.0.*, use
  'Eigen::Map<Eigen::SparseMatrix>'

## Release workflow

- Do not bump `DESCRIPTION`, do not update `NEWS.md` or `ChangeLog`. 
- Create a `.patch` file (see bWGR-Eigen5.patch for the final patch)
- Apply the patch using: `git apply bWGR-Eigen5.patch`

## Building and verifying

- Use `R CMD build .` to create a source tar.gz. 
- Use `R CMD check --no-manual --no-vignettes` on the source tar.gz. 
- Use directory `lib` here to install any packages needed only temporarily.
- Build against both RcppEigen 0.3.4.0.2 (in /home/edd/lab/rcppeigen/RcppEigen-0.3.4.0.2) and RcppEigen 0.4.9.9-5 (installed in lib/) to verify compatibility.

## Conventions

- Do not add code comments unless asked.
