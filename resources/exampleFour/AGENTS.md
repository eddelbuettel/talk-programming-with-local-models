# AGENTS.md: Instructions for an RcppEigen update

Guidance for working in this repository. It summarizes the project, any known
quirks, and the workflow used to build/verify changes so sessions can pick up
context quickly. Adjust as needed.

## Project

Package `fdaPDE` uses package `RcppEigen`. With the newest development
version of `RcppEigen` it results in a compilation error. The goal is to
make it compatible with both 
- **RcppEigen 0.3.4.0.2** (Eigen 3.4.x)
- **RcppEigen 0.4.9.9-5** (Eigen 5.0+)

## Problem Statement

There are two known sources of error with Eigen 5.0.*:

- `Eigen::all` is no longer available in Eigen 5.0.*. 
  - **Fix**: Use `Eigen::indexing::all` instead
  - This needs preprocessor protection for Eigen 5.0.*.
   
- `Eigen::MappedSparseMatrix` is no longer available in Eigen 5.0.*
   - **Fix**: Use `Eigen::Map<Eigen::SparseMatrix>` instead
   - This is available in Eigen 3.4.x and does not need preprocessor protection

When implementing changes, guard the changes with C preprocessor conditional
compilation with `EIGEN_VERSION_AT_LEAST()`

## Release workflow

- Do not bump `DESCRIPTION`, do not update `NEWS.md` or `ChangeLog`. 
- Use files in directory 'fdaPDE.orig/' as the reference copy, do not change it.
- Make changes in directory 'fdaPDE/'
- Create a 'patch' file using `diff` as there are no git repositories here. 

## Building and verifying

- Use `R CMD INSTALL ` to install from source directory or source tar.gz file.
- Use `R CMD build .` to create a source tar.gz. 
- Use `R CMD check --no-manual --no-vignettes` on the source tar.gz. 
- Use directory `lib` here to install any packages needed only temporarily.
- Build against both RcppEigen 0.3.4.0.2 (in /home/edd/lab/rcppeigen/RcppEigen-0.3.4.0.2) and RcppEigen 0.4.9.9-5 (installed in lib/) to verify compatibility.
- Ignore any latex or pdf issues.
- Do not add code comments unless asked.

## Plan

- Write a concise and succinct file 'PLAN.md' summarizing your changes.
