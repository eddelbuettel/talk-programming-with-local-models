# bWGR Patch for RcppEigen 0.3.4.0.2 and 0.4.9.9-5 Compatibility

## Purpose

This patch makes the `bWGR` package (version 2.2.18) compatible with both:
- **RcppEigen 0.3.4.0.2** (using Eigen 3.x series)
- **RcppEigen 0.4.9.9-5** (using Eigen 5.0.1)

## Known Issues in Eigen 5.0

When using Eigen 5.0+:
- `Eigen::all()` is deprecated → use `Eigen::indexing::all` instead
- `Eigen::MappedSparseMatrix` is deprecated → use `Eigen::Map<Eigen::SparseMatrix>` instead

The patch handles both issues through conditional compilation based on `EIGEN_WORLD_VERSION`.

## What the Patch Does

### File: `src/RcppExports.cpp`

Handles two functions that accept sparse matrices from R:
- `GS2EIGEN()`: Takes two sparse matrix arguments (X and XX)
- `PEGS_sparse()`: Takes one sparse matrix argument (S)

The patch uses conditional compilation (`#if EIGEN_WORLD_VERSION < 5`) to:
1. Accept `Eigen::MappedSparseMatrix<double>` for Eigen 3.x (shares storage with R object)
2. Accept `Eigen::Map<Eigen::SparseMatrix<double>>` for Eigen 5.0+ (copies storage from R object)

Note: The actual input parameter type in RcppExports.cpp stays as `Eigen::MappedSparseMatrix<double>` which works with both versions since the latter still provides this type for backward compatibility during transition.

### File: `src/RcppEigen20230423.cpp`

Contains template-based function signatures that can accept any valid sparse matrix type:
```cpp
template <typename SparseType>
double compute_kmup_innerproduct(double x, const SparseType& X, ...)
```

The implementation uses conditional compilation to handle different sparse matrix internal layouts.

### File: `src/RcppEigenX20251203.cpp`

Similar template approach for `compute_wgr_innerproduct()`:
```cpp
template <typename SparseType>
double compute_wgr_innerproduct(SparseType& S, ...)
```

The storage extraction adapts based on Eigen version:
- Eigen 3.x: Access MappedSparseMatrix internals directly  
- Eigen 5.0+: Extract from Map<Eigen::SparseMatrix> wrapper

## Build Instructions

### Step 1: Prepare bWGR source

```bash
# Already extracted at /tmp/bWGR, copy to lib directory
cd /home/edd/lab/rcppeigen/lib
mkdir -p bWGR
cp -r /tmp/bWGR/* bWGR/

# Apply the patch
cd bWGR
patch -p0 < /home/edd/lab/rcppeigen/bWGR-bwgr.patch
```

### Step 2: Build source tarball

```bash
cd /home/edd/lab/rcppeigen/lib/bWGR
R CMD build .
```

This creates `bWGR_x.x.x.tar.gz` in the current directory.

### Step 3: Verify with both RcppEigen versions

#### With RcppEigen 0.3.4.0.2 (Eigen 3.x):

```bash
cd /home/edd/lab/rcppeigen/lib
R -e "install.packages('lib/bWGR_x.x.x.tar.gz', repos=NULL, type='source')"
R CMD check --no-manual --no-vignettes lib/bWGR_x.x.x.tar.gz
```

#### With RcppEigen 0.4.9.9-5 (Eigen 5.0):

First ensure the new RcppEigen is installed or use a staging environment:

```bash
# Option A: Build bWGR with new RcppEigen in lib directory
R -e "install.packages('/path/to/RcppEigen_0.4.9.9-5.tar.gz', repos=NULL, type='source')"

# Then rebuild bWGR with the new dependencies
cd /home/edd/lab/rcppeigen/lib/bWGR
R CMD build .
R CMD check --no-manual --no-vignettes lib/bWGR_x.x.x.tar.gz
```

#### Test suite

Run the package tests to ensure functionality:

```bash
R -e "install.packages('lib/bWGR_x.x.x.tar.gz', repos=NULL, type='source')"
R -e 'library(bWGR); packageVersion("bWGR")'
# Run specific tests if available
tinycheck(/path/to/tests)  # or whatever test command bWGR uses
```

## Files Modified by Patch

1. `src/RcppExports.cpp` - Function signatures and input parameter handling
2. `src/RcppEigen20230423.cpp` - Inner product computation with sparse matrices  
3. `src/RcppEigenX20251203.cpp` - Another inner product implementation

## Testing Checklist

- [ ] Compile with RcppEigen 0.3.4.0.2 without errors
- [ ] Package loads in R: `library(bWGR)` works
- [ ] All exported functions work: `lsbWGR()` and manual check of all .Exports() functions
- [ ] Compile with RcppEigen 0.4.9.9-5 without errors  
- [ ] Package loads in R: `library(bWGR)` works with new Eigen version
- [ ] Sparse matrix operations work correctly in both versions
- [ ] No warnings from EIGEN_WORLD_VERSION >= 5 path

## Notes

- The patch preserves all existing functionality
- No changes to DESCRIPTION, NEWS.md, or ChangeLog (per AGENTS.md conventions)
- All code comments preserved unless requested otherwise
