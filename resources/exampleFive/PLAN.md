## Audit Summary

`prrd` (0.1.0, 2026-11-07) builds and passes `R CMD check --as-cran` cleanly. The recent migration from `filelock` to SQLite `BEGIN IMMEDIATE` locking is a good direction, but the audit found latent bugs and robustness gaps, especially around empty inputs, recovery of crashed workers, missing database tables, script option parsing, and an undefined variable in extended summaries.

## Proposed Plan

### Phase 1 — Critical Bugs

#### 1. Fix zero-length loops in enqueue functions
**File:** `R/enqueue.R`

Both `enqueueJobs` and `enqueueDepends` use `for (i in 1:n)`. In R, `1:0` is `c(1, 0)`, so a zero-row input loops twice and errors.

- Replace `for (i in 1:n)` with `for (i in seq_len(n))`.
- Guard `enqueueJobs` when `nrow(work) == 0` by returning `list_messages(q)` early.
- Guard `enqueueDepends` when `length(needed) == 0`.

#### 2. Fix undefined `wd` in extended summaries
**File:** `R/summarise.R`, function `.runExtended`

`wd` is only assigned when `cfg$workdir` exists. If no config or no workdir, `.checkfile(wd, pkg)` fails with “object 'wd' not found”.

- Initialize `wd <- getwd()` before config handling.
- Create `wd` with `dir.create(wd, recursive = TRUE, showWarnings = FALSE)` when needed.

#### 3. Make `summariseQueue` robust to missing tables
**File:** `R/summarise.R`

If no dequeue has run yet, `results` does not exist and `summariseQueue` errors.

- Use `DBI::dbListTables(con)` and treat missing `results`, `metadata`, or `qqjobs` as empty data.tables.
- Return `invisible(NULL)` or an empty result gracefully.

#### 4. Create the `results` table at enqueue time
**File:** `R/enqueue.R`

`enqueueJobs` currently creates only `metadata`. This makes `summariseQueue` fail before any dequeue.

- Call `createTableLocked(db)` in `enqueueJobs` right after `createRunDataTableLocked(db)`.

#### 5. Recover crashed workers at dequeue startup
**File:** `R/dequeue.R`, function `dequeueJobs`

`requeue_failed_messages(q)` is only called in verbose mode at the end. Crashed workers can leave jobs in `WORKING`.

- Call `requeue_failed_messages(q)` before the main `while (!is.null(msg <- try_consume(q)))` loop.
- Also call it in `dequeueDepends`.

#### 6. Guard `download.packages` failure
**File:** `R/dequeue.R`

If `download.packages` returns `NULL`, `basename(dl[,2])` errors.

- Check `is.null(dl)` and stop with a clear message, or skip the package with `rc <- 1`.

#### 7. Fix script usage header typo
**File:** `inst/scripts/enqueueJobs.r`

`[Usage:` is not recognized by `docopt`.

- Change to `Usage:`.

### Phase 2 — Robustness and Consistency

#### 8. Restore working directory safely
**File:** `R/dequeue.R`

`setwd(wd)` / `setwd(cwd)` are not protected if an error occurs mid-job.

- Wrap the per-job body in `tryCatch` or use `on.exit(setwd(cwd), add = TRUE)`.

#### 9. Consistent directory creation
**Files:** `R/dequeue.R`, `R/summarise.R`, `R/enqueue.R`

Several `dir.create` calls lack `recursive = TRUE`.

- Use `dir.create(..., recursive = TRUE, showWarnings = FALSE)` consistently for `wd`, `libdir`, and extended-summary directories.

#### 10. Make `normalizePath` non-fatal for new directories
**Files:** `R/dequeue.R`, `R/enqueue.R`, `R/summarise.R`

`normalizePath(cfg$libdir)` warns or fails when the directory does not yet exist.

- Use `normalizePath(cfg$libdir, mustWork = FALSE)`.

#### 11. Guard config `setup` when empty
**Files:** `R/dequeue.R`, `R/enqueue.R`, `R/summarise.R`

`source(cfg$setup)` errors if `setup` is `""`.

- Use `if (nzchar(cfg$setup)) source(cfg$setup)`.

#### 12. Reorder config loading before sanity checks
**File:** `R/dequeue.R`

`runSanityChecks()` runs before config is loaded, so locale/setup changes in config are too late.

- Load config and source `setup` first, then call `runSanityChecks()`.

#### 13. Improve locale check
**File:** `R/checks.R`

`Sys.getlocale()` checks only the default category.

- Check `Sys.getlocale("LC_CTYPE")` and `Sys.getlocale("LC_COLLATE")`.

#### 14. Align legacy DB helpers with new locking
**File:** `R/db.R`

`createTable`, `insertRow`, and `createRunDataTable` still use `BEGIN EXCLUSIVE`.

- Rewrite them to use `dbWithWriteTransaction` / `BEGIN IMMEDIATE`, or mark them deprecated in favor of the `*Locked` variants.

#### 15. Safer defaults for `dbWriteTableLocked`
**File:** `R/db.R`

Default `overwrite = TRUE` is dangerous for a helper.

- Change defaults to `append = TRUE, overwrite = FALSE`.

#### 16. Tune SQLite pragmas
**File:** `R/db.R`

- Increase `busy_timeout` from `2000` to `5000`.
- Set `PRAGMA synchronous = NORMAL` in WAL mode.
- Avoid repeatedly setting `journal_mode = WAL` on every connection; set it once at queue creation.

#### 17. Improve exclusion-set parsing
**File:** `R/utils.R`, function `getExclusionSet`

Headerless CSV files lose the first package name.

- Use `readLines` and trim whitespace, or `scan(what = character())`.

#### 18. Validate queue/package names
**File:** `R/dequeue.R`

Messages come from the queue, but validation prevents path traversal or command misuse.

- Validate `tok[1]` against `^[A-Za-z][A-Za-z0-9.]*$` before use.

### Phase 3 — Scripts and Dependencies

#### 19. Fix `docopt` usage patterns
**Files:** `inst/scripts/dequeueJobs.r`, `inst/scripts/enqueueJobs.r`

`-h`/`-x` cannot be used without the required positional argument.

- Make `PACKAGE` optional in the usage string, or parse flags before requiring positional arguments.

#### 20. Resolve script dependency declarations
**Files:** `DESCRIPTION`, `inst/scripts/*.r`

Scripts require `docopt` and `anytime`, currently only `Suggests`.

- Either move `docopt` and `anytime` to `Imports`, or rewrite scripts to use base R (`commandArgs`, `as.Date`) to preserve tinyverse frugality.

#### 21. Fix filename/spelling mismatches
**Files:** `inst/scripts/summariseJobs.r`, docs

- Align documented script name with actual filename (`summariseJobs.r`).
- Fix typos: “Summarisse”, “swith”, “detauls”.

### Phase 4 — Documentation, Testing, and Cleanup

#### 22. Documentation improvements
**Files:** `man/*.Rd`, `README.md`

- Clarify return values of `dequeueJobs` and `summariseQueue`.
- Document `dbLock` and `*Locked` helpers as internal.
- Add a short “troubleshooting/recovery” section for crashed workers and stale locks.

#### 23. Add offline unit tests
**New:** `tests/testthat/` or `inst/tinytest/`

- Test `getDataDirectory`, `getQueueFile`, `getConfig`, `getExclusionSet`.
- Test empty-input enqueue loops (`seq_len`).
- Test `.runExtended` with no config (undefined `wd` regression).
- Test missing-table handling in `summariseQueue`.
- Keep tests free of network/CRAN access.

#### 24. CI improvements
**File:** `.github/workflows/ci.yaml`

- Run the offline tests in CI.
- Optionally test script executability (`Rscript inst/scripts/... -h`).

#### 25. Minor cleanup
**Files:** `R/*.R`

- Remove unused locals (`debug`, `env`, `verbose` in `.runExtended`; `lst` in `dequeueJobs`; `.onLinux` in `runSanityChecks`).
- Ensure `globalVariables` declarations remain accurate after changes.

### Implementation Notes

- Preserve public API and existing behavior; changes should be backward-compatible.
- Do not alter `DESCRIPTION` imports unless the dependency decision in Phase 3 is accepted.
- Do not modify `ChangeLog` or `inst/NEWS.Rd` unless release notes are explicitly requested.
- Validate all changes with `R CMD build` and `R CMD check --as-cran` before release.