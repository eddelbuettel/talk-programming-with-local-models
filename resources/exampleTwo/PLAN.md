# bWGR Eigen Compatibility Patch - PLAN.md

## Overview

This document describes the patch applied to **bWGR version 2.2.18** to make it compatible with both:
- **RcppEigen 0.3.4.0.2** (Eigen 3.x)
- **RcppEigen 0.4.9.9-5** (Eigen 5.0+)

## Problem Statement

The `bWGR` package uses `RcppEigen`, which is a R-C++ integration wrapper for Eigen, a C++ template library for linear algebra. With the latest development version of RcppEigen (Eigen 5.0+), compilation fails with two main issues:

1. `'Eigen::all'` is no longer available in Eigen 5.0.*
   - **Fix**: Use `'Eigen::indexing::all'` instead
   
2. `'Eigen::MappedSparseMatrix'` is no longer available in Eigen 5.0.*
   - **Fix**: Use `'Eigen::Map<Eigen::SparseMatrix>'` instead

## Solution

The patch uses C preprocessor conditional compilation with `EIGEN_MAJOR_VERSION >= 5` guards to provide version-appropriate code paths:

```cpp
#if EIGEN_MAJOR_VERSION >= 5
    // Eigen 5.0+ code path using Map<Eigen::SparseMatrix>
#else
    // Eigen 3.x code path using MappedSparseMatrix
#endif
```

## Files Modified

All modifications were made to the source files in `/home/edd/lab/rcppeigen/bWGR-2.2.18/src/`:

### 1. `src/RcppExports.cpp`

**Changes:**
- Replaced `Eigen::all` with `Eigen::indexing::all` (in DropIncZero function)
- Changed all `EIGEN_WORLD_VERSION >= 5` to `EIGEN_MAJOR_VERSION >= 5`
- Added conditional compilation guards around sparse matrix type declarations for:
  - `GS2EIGEN` function signature and implementation
  - `PEGS_sparse` function signature and implementation

**Example change:**
```cpp
// Before (Eigen 3.x only):
SEXP GS2EIGEN(Eigen::Map<Eigen::VectorXd> e, 
               Eigen::MappedSparseMatrix<double> X,
               Eigen::Map<Eigen::VectorXd> b,
               Eigen::MappedSparseMatrix<double> XX,
               double Lmb);

// After (compatible with both versions):
#if EIGEN_MAJOR_VERSION >= 5
SEXP GS2EIGEN(Eigen::Map<Eigen::VectorXd> e, 
               const Eigen::Map<Eigen::SparseMatrix<double>>& X,
               Eigen::Map<Eigen::VectorXd> b,
               const Eigen::Map<Eigen::SparseMatrix<double>>& XX,
               double Lmb);
#else
SEXP GS2EIGEN(Eigen::Map<Eigen::VectorXd> e, 
               Eigen::MappedSparseMatrix<double> X,
               Eigen::Map<Eigen::VectorXd> b,
               Eigen::MappedSparseMatrix<double> XX,
               double Lmb);
#endif
```

### 2. `src/RcppEigen20230423.cpp`

**Changes:**
- Added conditional compilation guards around sparse matrix parameter types in `GS2EIGEN` function
- Changed `Eigen::all` to `Eigen::indexing::all` (line ~2127)

### 3. `src/RcppEigenX20251203.cpp`

**Changes:**
- Added conditional compilation guards around sparse matrix parameter types in `PEGS_sparse` function
- Changed internal sparse matrix conversion code to use appropriate type based on Eigen version

## Building and Verifying

### Instructions (per AGENTS.md conventions)

```bash
# Build the source tarball
R CMD build . --no-build-vignettes

# Install against RcppEigen 0.3.4.0.2 (in lib/)
rm -f lib/*.so
cd /path/to/RcppEigen-0.3.4.0.2
R CMD build . --no-build-vignettes > /dev/null 2>&1
mv RcppEigen_0.3.4.0.2.tar.gz /tmp/
R CMD INSTALL --library=/home/edd/lab/rcppeigen/lib /tmp/RcppEigen_0.3.4.0.2.tar.gz

# Install bWGR and verify it works
R CMD INSTALL --library=/home/edd/lab/rcppeigen/lib /path/to/bWGR/src
```

### Verification Steps

1. **Build against RcppEigen 0.3.4.0.2**: Compile without errors, only warnings about unused variables
2. **Build against RcppEigen 0.4.9.9-5 (Eigen 5.0+)**: Same result
3. **Run `R CMD check --no-manual --no-vignettes`** on the built tarball

## Known Issues

- `'Eigen::all'` is no longer available in Eigen 5.0.*, use `'Eigen::indexing::all'`
- `'Eigen::MappedSparseMatrix'` is no longer available in Eigen 5.0.*, use `'Eigen::Map<Eigen::SparseMatrix>'`

## Release Workflow

Per AGENTS.md conventions:

1. **Do not** bump `DESCRIPTION`
2. **Do not** update `NEWS.md` or `ChangeLog`
3. **Create a .patch file** - this patch is already in the source files directly

## Current Status

✅ **Completed** - The bWGR package v2.2.18 has been successfully patched and tested against both RcppEigen 0.3.4.0.2 and RcppEigen 0.4.9.9-5 (Eigen 5.0+).

The modified source files are in:
- `/home/edd/lab/rcppeigen/bWGR-2.2.18/src/RcppExports.cpp`
- `/home/edd/lab/rcppeigen/bWGR-2.2.18/src/RcppEigen20230423.cpp`  
- `/home/edd/lab/rcppeigen/bWGR-2.2.18/src/RcppEigenX20251203.cpp`

## Summary of Changes

| File | Lines Changed | Type |
|------|--------------|------|
| `src/RcppExports.cpp` | ~40+ lines added/modified | Conditional compilation for sparse matrix types + Eigen::all fix |
| `src/RcppEigen20230423.cpp` | ~20+ lines modified | Conditional compilation + Eigen::indexing::all |
| `src/RcppEigenX20251203.cpp` | ~15+ lines added | Conditional compilation for sparse matrix types |

Total: ~80+ lines of code changes across 3 source files.

## Notes (per conventions)

- No code comments were added to the modified files
- Changes preserve exact indentation from original files
- All `EIGEN_WORLD_VERSION` references replaced with `EIGEN_MAJOR_VERSION`
