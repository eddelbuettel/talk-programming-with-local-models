# Plan for fdaPDE RcppEigen Compatibility Update

## Changes Made

### 1. FdaPDE.h (`fdaPDE/src/FdaPDE.h`)
Added Eigen version detection after `#include <Rcpp.h>`:

```cpp
// Check Eigen version for conditional compilation
#if defined(EIGEN_WORLD_VERSION) && defined(EIGEN_MAJOR_VERSION)
#define EIGEN_EPOCH_VERSION ((EIGEN_WORLD_VERSION * 10000) + (EIGEN_MAJOR_VERSION * 100) + EIGEN_MINOR_VERSION)
#else
#define EIGEN_EPOCH_VERSION 0
#endif
```

This provides a unified version check using epoch format where:
- Eigen 3.x = versions < 50000  
- Eigen 5.x+ = versions >= 50000

### 2. Kronecker_Product.cpp (`fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp`)
Modified line ~103 to use conditional compilation for the sparse matrix construction:

**Before:**
```cpp
Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt> ABM(ABr, ABc, ABnz, 
                                                           ABouter.data(), 
                                                           ABinner.data(), 
                                                           ABvalues.data());
SpMat AB(ABM);
```

**After (with guards):**
```cpp
#if EIGEN_EPOCH_VERSION >= 50000
    // Eigen 5.x+: MappedSparseMatrix removed, construct and populate directly
    SpMat AB(ABr, ABc);
    for (UInt k = 0; k < ABnz; ++k) {
        AB.insert(ABouter[k], ABinner[k]) = ABvalues[k];
    }
#else
    // Eigen 3.x: Use MappedSparseMatrix
    Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt> ABM(ABr, ABc, ABnz, 
                                                                 ABouter.data(), 
                                                                 ABinner.data(), 
                                                                 ABvalues.data());
    SpMat AB(ABM);
#endif
```

## Rationale

- **No changes for `Eigen::all`**: This function is not used anywhere in the fdaPDE codebase.
- **MappedSparseMatrix fix**: For Eigen 5.x+, `MappedSparseMatrix` was deprecated/removed. The new approach constructs a sparse matrix directly with constructor arguments and populates it via insertions.
- **Version detection**: Uses `EIGEN_WORLD_VERSION`, `EIGEN_MAJOR_VERSION`, and `EIGEN_MINOR_VERSION` macros exposed by Rcpp.h (included before Eigen headers).

## Files Modified

1. `fdaPDE/src/FdaPDE.h` - Added version detection macros
2. `fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp` - Conditional compilation for sparse matrix construction

## Files Not Modified (Reference Copy)

- All files under `fdaPDE.orig/` remain unchanged as the reference copy

## Patch File

A patch file has been created at `/home/edd/lab/rcppeigen/patch` using `diff`.

## Build and Verification

Per the AGENTS.md workflow:
1. Use `R CMD build .` to create source tar.gz from `fdaPDE/`
2. Use `R CMD check --no-manual --no-vignettes` on the source tar.gz  
3. Install RcppEigen 0.3.4.0.2 and 0.4.9.9-5 in `lib/` 
4. Build against both RcppEigen versions to verify compatibility
5. Ignore latex/pdf issues during checks
