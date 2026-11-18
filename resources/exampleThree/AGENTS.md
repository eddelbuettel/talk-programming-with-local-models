# AGENTS.md: Instructions for an RcppEigen update

Guidance for working in this repository. It summarizes the project, any known
quirks, and the workflow used to build/verify changes so sessions can pick up
context quickly. Adjust as needed.

## Project

Package `fdaPDE` uses package `RcppEigen`. With the newest development
version of `RcppEigen` it results in a compilation error. The goal is to
make it compatible with both:
- **RcppEigen 0.3.4.0.2** (Eigen 3.x)
- **RcppEigen 0.4.9.9-5** (Eigen 5.0+)

## Problem Statement

1. `'Eigen::all'` is no longer available in Eigen 5.0.*. 
   - **Fix**: Use `'Eigen::indexing::all'` instead
   
2. `'Eigen::MappedSparseMatrix'` is no longer available in Eigen 5.0.*
   - **Fix**: Use `'Eigen::Map<Eigen::SparseMatrix>'` instead

Guard changes with C preprocessor conditional compilation with
`EIGEN_MAJOR_VERSION >= 5` to provide version-appropriate code paths:

```cpp
#if EIGEN_MAJOR_VERSION >= 5
    // Eigen 5.0+ code path using Map<Eigen::SparseMatrix> or Eigen::indexing::all
#else
    // Eigen 3.x code path using MappedSparseMatrix or Eigen::all
#endif
```

## Release workflow

- Do not bump `DESCRIPTION`, do not update `NEWS.md` or `ChangeLog`. 
- Use files in directory 'fdaPDE.orig/' as the reference copy, do not change it.
- Make changes in directory 'fdaPDE/'
- Create a 'patch' file using `diff` as there are no git repositories here. 

## Building and verifying

- Use `R CMD build .` to create a source tar.gz. 
- Use `R CMD check --no-manual --no-vignettes` on the source tar.gz. 
- Use directory `lib` here to install any packages needed only temporarily.
- Build against both RcppEigen 0.3.4.0.2 (in /home/edd/lab/rcppeigen/RcppEigen-0.3.4.0.2) and RcppEigen 0.4.9.9-5 (installed in lib/) to verify compatibility.
- Ignore any latex or pdf issues.

## Conventions

- Do not add code comments unless asked.

## Plan

- Write a concise and succinct file 'PLAN.md' summarizing your changes.
