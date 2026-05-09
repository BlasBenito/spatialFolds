# TODO

## Urgent Fixes

- [ ] **Fix `spatial_thinning()` target method** — last commit notes it doesn't work. Debug the call chain from `spatial_thinning()` → `validate_arg_target()` → `thinning_to_target()` (C++).
- [ ] **Commit untracked test files** — `tests/testthat/test-validate_arg_distance.R` and `test-validate_arg_target.R` are untracked (`??` in git status).
- [ ] **Fix binary search tolerance in `method_contiguous_planar.cpp`** — fixed absolute tolerance `0.01` breaks for projected CRS (meters). Replace with relative tolerance (e.g., `1e-4 * scale`).
- [ ] **Add bounds checking in `method_blocks.cpp`** — `block_id[i]` accessed without bounds check (lines 68–70); can cause undefined behavior with malformed input.

## Nice to Have

- [ ] **rsample integration** — implement `spatial_contiguous_cv()` and `spatial_blocks_cv()` returning rsample-compatible `rset` objects. `rsample` is already in `Imports`. README already hints at this.
- [ ] **Fold quality metrics** — function to evaluate spatial separation between training and testing sets (e.g., nearest-neighbor distance distributions or Moran's I reduction).
- [ ] **Expand spherical contiguous tests** — `method_contiguous_spherical()` has only 1 test vs 14 for planar. Add dateline-crossing, polar, and full-globe cases.
- [ ] **Performance vignette** — benchmark spatialFolds against blockCV and ENMeval on a realistic dataset.

## Documentation

- [ ] **Write vignettes**:
  - Spatial CV workflow: `spatial_folds()` → `spatial_fold_plot()` → `deduplicate_folds()`
  - Spatial thinning workflow: distance vs target methods with real geographic data
- [ ] **Complete `_pkgdown.yml`** — set URL, organize reference page by `@family`, wire up vignettes.
- [ ] **Update `NEWS.md`** — replace placeholder with actual version history.
- [ ] **CRAN preparation** — 0 errors/warnings/notes in `R CMD check`, finalize version number.
