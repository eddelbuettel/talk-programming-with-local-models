# Plan

1.  **Identify and fix `Eigen::MappedSparseMatrix` usage.**
    -   Found one instance in `fdaPDE/src/FE_Assemblers_Solvers/Source/Kronecker_Product.cpp`.
    -   Replace `Eigen::MappedSparseMatrix<Real, Eigen::ColMajor, UInt>` with `Eigen::Map<Eigen::SparseMatrix<Real, Eigen::ColMajor, UInt>>`.
2.  **Identify and fix `Eigen::all` usage.**
    -   Searched for `Eigen::all` and `all` in indexing context.
    -   No explicit `Eigen::all` found in `fdaPDE/src`.
    -   Will double-check if any `all` is used as a proxy for `Eigen::all`.
3.  **Generate patch file.**
    -   Create a `patch` file with the changes made.
