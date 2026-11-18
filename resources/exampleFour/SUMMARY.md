# Summary of Changes for RcppEigen Compatibility

This summary contains the plan, the resulting patch, and verification notes for making `fdaPDE` compatible with `RcppEigen-0.4.9.9-5` (Eigen 5.0+).

## Plan

1.  **Identify and fix `Eigen::MappedSparseMatrix` usage.**
    -   Found one instance in `fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp`.
    -   Replace `Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt>` with `Eigen::Map<Eigen::SparseMatrix<Real, Eigen::ColMajor, UInt>>`.
2.  **Identify and fix `Eigen::all` usage.**
    -   Searched for `Eigen::all` and `all` in indexing context.
    -   No explicit `Eigen::all` found in `fdaPDE/src`.
    -   Will double-check if any `all` is used as a proxy for `Eigen::all`.
3.  **Generate patch file.**
    -   Create a `patch` file with the changes made.

## Patch

```patch
--- fdaPDE.orig/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp	2026-06-01 07:10:59.000000000 +0000
+++ fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp	2026-11-14 17:59:23.186129046 +0000
@@ -100,7 +100,7 @@
 		Acurrent = Aouter[i];
 	}
 
-	Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt> ABM(ABr, ABc, ABnz, ABouter.data(), ABinner.data(), ABvalues.data());
+	Eigen::Map<Eigen::SparseMatrix<Real, Eigen::ColMajor, UInt>> ABM(ABr, ABc, ABnz, ABouter.data(), ABinner.data(), ABvalues.data());
 	SpMat AB(ABM);
 
 //	delete[] ABvalues;
```

## Verification Notes

-   **RcppEigen 0.3.4.0.2 (Eigen 3.4.x)**: The new code uses `Eigen::Map<Eigen::SparseMatrix>`, which is compatible with both Eigen 3.4 and 5.0.
-   **RcppEigen 0.4.9.9-5 (Eigen 5.0+)**: The fix addresses the removal of `Eigen::MappedSparseMatrix`.
-   No changes were made to `DESCRIPTION`, `NEWS.md`, or `ChangeLog` as per instructions.
