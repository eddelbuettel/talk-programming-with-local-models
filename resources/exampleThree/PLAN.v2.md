# Plan for fdaPDE RcppEigen Compatibility Update

## Changes Made

### 1. FdaPDE.h (`fdaPDE/src/FdaPDE.h`)
No changes needed - `EIGEN_VERSION_AT_LEAST` is already available via `Rcpp.h`.

### 2. Kronecker_Product.cpp (`fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp`)
Modified line ~103 to use conditional compilation with `EIGEN_VERSION_AT_LEAST`:

**Before:**
```cpp
Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt> ABM(ABr, ABc, ABnz, 
                                                           ABouter.data(), 
                                                           ABinner.data(), 
                                                           ABvalues.data());
SpMat AB(ABM);
```

**After:**
```cpp
#if EIGEN_VERSION_AT_LEAST(5,0,0)
    // Eigen 5.x+: MappedSparseMatrix removed, use Map<Eigen::SparseMatrix<> >
    Eigen::Map<Eigen::SparseMatrix<Real,Eigen::ColMajor,UInt>, 1, Eigen::MapOptions<0>> ABM(ABouter.data(), ABinner.data(), ABvalues.data(), ABr, ABc, ABnz);
    SpMat AB(ABM);
#else
    // Eigen 3.x/4.x: Use MappedSparseMatrix (which wraps Map<Eigen::SparseMatrix<> >)
    Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt> ABM(ABr, ABc, ABnz, 
                                                                 ABouter.data(), 
                                                                 ABinner.data(), 
                                                                 ABvalues.data());
    SpMat AB(ABM);
#endif
```

## Rationale

- **No changes for `Eigen::all`**: Not used in the codebase.
- **MappedSparseMatrix fix**: For Eigen 5.x+, use `Eigen::Map<Eigen::SparseMatrix<>, ...>` directly with reordered constructor arguments (pointers first, dimensions last). For older versions, `MappedSparseMatrix` wrapper handles compatibility automatically.
- **Version detection**: Uses `EIGEN_VERSION_AT_LEAST(major, minor, patch)` macro from RcppEigen (already available after `#include <Rcpp.h>`).

## Files Modified

1. `fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp` - Conditional compilation for sparse matrix mapping

## Files Not Modified

- All files under `fdaPDE.orig/` remain unchanged as the reference copy

## Patch File

Created at `/home/edd/lab/rcppeigen/patch`.
