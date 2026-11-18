# Plan for RcppEigen Compatibility with Eigen 3.4.x and Eigen 5.0+

## Goal
The objective is to update the `fdaPDE` package to be fully compatible with two distinct versions of the Eigen library:
1. **Eigen 3.4.x** (Legacy support)
2. **Eigen 5.0+** (Newer standard)

## Problem Statement
The following Eigen usages are known to be incompatible or change between versions:
- `Eigen::all`: No longer available in Eigen 5.0+.
  - **Fix**: Must be replaced with `Eigen::indexing::all`.
- `Eigen::MappedSparseMatrix`: Deprecated/unavailable in Eigen 5.0+.
   - **Fix**: Must be replaced with `Eigen::Map<Eigen::SparseMatrix>`.

## Strategy
The compatibility will be achieved using C preprocessor conditional compilation guards (`#ifdef`, `#if`, etc.) wrapped around the critical sections of code. This ensures that the correct Eigen usage is compiled based on the detected library version.

## Workflow Steps
1. **Code Inspection (Current Step):** Identify all files within the `fdaPDE/` directory that contain usages of `Eigen::all` or `Eigen::MappedSparseMatrix`.
2. **Implementation:** Modify the identified files in `fdaPDE/` by wrapping the problematic code in version checks.
3. **Verification:** Build and verify the code against both the Eigen 3.4.x and Eigen 5.0+ environments as per the standard RcppEigen build process.
4. **Final Output:** Generate a patch file using `diff` to represent all required changes, comparing the working directory (`fdaPDE/`) against the reference directory (`fdaPDE.orig/`).

## Important Notes
*   Do not modify `DESCRIPTION`, `NEWS.md`, or `ChangeLog`.
*   Changes must be contained within the `fdaPDE/` directory.
*   The final result must be a single patch file.