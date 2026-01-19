# spatialFolds Package Assessment

**Assessment Date:** January 2026
**Package Version:** 0.1.0
**Overall Rating:** 8.5/10

---

## Executive Summary

The spatialFolds package is well-engineered with strong test coverage (~180 tests), clean architecture, and modern R practices. The C++ implementations are correct and performant. The main areas for improvement are documentation completeness (missing vignettes), some naming inconsistencies, and minor gaps in test coverage for spherical geometry and parallel execution.

---

## 1. Function Naming Coherence

### Strengths

- **Consistent snake_case**: All function names use snake_case with no camelCase mixing
- **Prefix-based organization**: Clear prefixes (`spatial_*`, `cast_*`, `method_*`, `utils_*`, `validate_arg_*`)
- **Error message consistency**: All messages prefixed with `spatialFolds::function_name():`

### Issues Identified

| Issue | Severity | Location | Recommendation |
|-------|----------|----------|----------------|
| Parameter `sf` conflicts with package name | HIGH | `cast_sf_to_bbox(sf = ...)` | Rename to `x` or `sf_obj` |
| Spherical functions scattered | MEDIUM | Multiple prefixes | Add `@family spherical` tags |
| `method` vs `methods` inconsistent | MEDIUM | `spatial_folds()` vs `spatial_thinning()` | Standardize naming |
| `block_ids()` unclear naming | LOW | `block_ids()` | Consider `compute_block_ids()` |

### Detailed Analysis

**Parameter `sf` Confusion:**
```r
# Current - confusing because sf is both parameter and package name:
cast_sf_to_bbox(sf = my_data)

# Recommended:
cast_sf_to_bbox(x = my_data)
```

**Scattered Spherical Functions:**
```r
# Current - user searching for "spherical" won't find all related functions:
utils_needs_spherical()           # utils prefix
method_contiguous_spherical()     # method prefix
cast_xy_to_xyz()                  # cast prefix (no "spherical" in name)

# Recommendation: Add @family spherical tags to all three
```

**Method vs Methods:**
```r
# Inconsistent:
spatial_folds(methods = c("contiguous", "random"))  # PLURAL
spatial_thinning(method = "distance")               # SINGULAR

# Both accept multiple values via match.arg(), but naming differs
```

---

## 2. Argument Naming Coherence

### Strengths

- Consistent coordinate column naming (`"x"`, `"y"`)
- Consistent logical vectors for training folds (TRUE = training)
- Consistent `seed` parameter name across all random functions

### Issues Identified

| Issue | Severity | Details |
|-------|----------|---------|
| `sf` parameter name | HIGH | Conflicts with package namespace |
| `blocks` parameter complexity | MEDIUM | Accepts NULL, integer, or c(rows, cols) |
| `spherical` NULL semantics | MEDIUM | NULL = auto-detect vs FALSE = explicit |
| `target` vs `training_fraction` | LOW | Different concepts but potentially confusing |

### `blocks` Parameter Complexity

The `blocks` parameter accepts three different input types with different meanings:
```r
spatial_folds(blocks = NULL)         # Auto-compute from data
spatial_folds(blocks = 10)           # Total block count (auto-layout)
spatial_folds(blocks = c(5, 10))     # Explicit rows and columns
```

**Recommendation:** Document more clearly in @param or consider helper constructors.

### `spherical` NULL Semantics

```r
# spatial_folds() - NULL means auto-detect:
spatial_folds(spherical = NULL)  # 3-state: TRUE/FALSE/NULL

# training_mask() - No auto-detection:
training_mask(spherical = FALSE)  # 2-state: TRUE/FALSE

# This inconsistency is confusing
```

---

## 3. Architecture Assessment

### Overall Rating: Excellent

The package demonstrates clean separation of concerns:

```
User Input (sf/data.frame)
    ↓
validate_arg_sf() → standardizes input
    ↓
cast_sf_to_xy() → extracts coordinates
    ↓
C++ methods (method_random, method_blocks, etc.)
    ↓
training_mask() wrapper
    ↓
spatial_folds() loop via future_lapply()
    ↓
Data frame of logical vectors
```

### Strengths

1. **Clear entry points**: `spatial_folds()` and `spatial_thinning()` as main functions
2. **Internal function exposure**: Lower-level functions exported for advanced users
3. **Validation layer**: Consistent `validate_arg_*()` pattern
4. **Parallel-ready**: Uses `future.apply::future_lapply()` for parallelization
5. **Progress tracking**: Integrates `progressr` non-intrusively
6. **tidymodels compatibility**: Returns rsample-compatible objects

### Function Organization

| Category | Count | Functions |
|----------|-------|-----------|
| Primary entry points | 2 | `spatial_folds()`, `spatial_thinning()` |
| Visualization | 1 | `spatial_fold_plot()` |
| Data conversion | 4 | `cast_df_to_sf()`, `cast_sf_to_xy()`, `cast_sf_to_bbox()`, `cast_xy_to_xyz()` |
| Grid utilities | 1 | `block_ids()` |
| Fold manipulation | 1 | `deduplicate_folds()` |
| Other utilities | 1 | `utils_needs_spherical()` |
| C++ methods (exported) | 6 | `method_*`, `thinning_*`, `training_mask()` |
| **Total Exported** | **15** | |

---

## 4. Usability Assessment

### Strengths

- Sensible defaults allow `spatial_folds(xy_sf)` to produce useful output
- Flexible input types (sf and data.frame both accepted)
- Good error messages with function name prefixes
- Reproducibility via seed parameter

### Issues

1. **Discovery problem**: Related spherical functions not grouped together
2. **Complex parameter semantics**: `blocks` parameter has 3 input modes
3. **Opaque auto-detection**: `spherical = NULL` auto-detection not obvious from signature
4. **No vignettes**: Missing long-form tutorials

### API Simplicity Rating: Good

The main functions have reasonable signatures:
```r
spatial_folds(
  df = NULL,
  methods = c("contiguous", "random", "blocks"),
  training_fraction = c(0.75, 0.5),
  repetitions = 30,
  seed = 1,
  blocks = NULL,
  spherical = NULL,
  quiet = FALSE
)
```

---

## 5. Potential Bugs

### C++ Implementation Issues

| Issue | Severity | File | Line | Description |
|-------|----------|------|------|-------------|
| Fixed tolerance in binary search | MEDIUM | `method_contiguous_planar.cpp` | 101 | `while (scale_max - scale_min > 0.01)` uses absolute tolerance that breaks for large scales |
| Unvalidated block_id | MEDIUM | `method_blocks.cpp` | 68-70 | No bounds check on `block_id[i]` before array access |
| Fallback may exceed target | LOW | `thinning_to_target.cpp` | 204-206 | If fallback triggers, result may exceed target count |

### Detailed Issue: Binary Search Tolerance

```cpp
// Current (problematic for large scales):
while (scale_max - scale_min > 0.01) {

// Recommended (relative tolerance):
while ((scale_max - scale_min) / (scale_max + 1e-10) > 0.0001) {
```

### Detailed Issue: Unvalidated block_id

```cpp
// Current (no bounds check):
for (int i = 0; i < n; i++) {
  cell_counts[block_id[i]]++;  // Potential buffer overflow
}

// Recommended:
for (int i = 0; i < n; i++) {
  if (block_id[i] < 0 || block_id[i] >= total_cells) {
    stop("Invalid block_id value %d at index %d", block_id[i], i);
  }
  cell_counts[block_id[i]]++;
}
```

---

## 6. Limitations

### Functional Limitations

1. **No support for weighted sampling**: All methods treat points equally
2. **Limited thinning methods**: Only distance-based; no density-based thinning
3. **Single geometry type**: Only POINT geometries supported (polygons converted to centroids)
4. **Fixed CRS handling**: Converts to WGS84 (4326) internally

### Scalability Considerations

- `method_random`: O(n) - Fisher-Yates shuffle, scales well
- `method_blocks`: O(n log k) - scales well
- `method_contiguous`: O(n) per iteration - scales well
- `thinning_to_distance`: O(n²) with grid optimization - may be slow for >100k points
- `thinning_to_target`: O(k × n²) - can be slow for large datasets

### Documentation vs Implementation Mismatch

`spatial_thinning.R` claims O(n²) complexity, but actual implementation uses grid-based indexing achieving O(n + m × k) where m = kept points, k ≈ 10-100.

---

## 7. Areas for Improvement

### High Priority

1. **Add vignettes**
   - Getting started tutorial
   - Spherical geometry guide
   - tidymodels integration workflow

2. **Fix C++ tolerance issue** in `method_contiguous_planar.cpp`

3. **Add bounds checking** in `method_blocks.cpp`

4. **Rename `sf` parameter** in `cast_sf_to_bbox()` to avoid namespace confusion

### Medium Priority

5. **Add parallel execution tests**
   ```r
   test_that("spatial_folds() works with future multisession", {
     plan("multisession", workers = 2)
     folds <- spatial_folds(xy_sf, repetitions = 10)
     plan("sequential")
     expect_equal(ncol(folds), 10)
   })
   ```

6. **Expand spherical geometry tests**
   - More dateline crossing scenarios
   - Pole behavior with various angular steps
   - Comparison between planar and spherical for local data

7. **Add `@family` tags** for better function discovery
   - `@family spherical` for spherical geometry functions
   - `@family casting` for data conversion functions
   - `@family validation` for validation functions

8. **Standardize `method` vs `methods`** parameter naming

### Low Priority

9. **Add CRS handling tests** for non-WGS84 inputs

10. **Consider renaming `block_ids()`** to `compute_block_ids()` for clarity

11. **Expand package-level documentation** in `spatialFolds-package.R`

12. **Add performance benchmarks** for regression detection

---

## 8. Test Coverage Analysis

### Strengths

- **~180 tests** with behavioral verification
- Tests verify algorithm properties, not just types
- Edge cases well-covered (empty input, single point, boundary conditions)
- Reproducibility tests for all stochastic methods
- Distribution uniformity verified for random methods

### Gaps

| Gap | Priority | Description |
|-----|----------|-------------|
| Parallel execution | HIGH | No tests verify `future_lapply()` correctness |
| Spherical edge cases | MEDIUM | Only 5 tests vs 9 for planar geometry |
| CRS handling | MEDIUM | No tests for non-4326 inputs |
| Performance regression | LOW | No benchmark tests |
| Visualization output | LOW | Tests verify no errors, not plot content |

---

## 9. Dependency Assessment

### Imports (6) - Minimal and Appropriate

| Package | Purpose | Assessment |
|---------|---------|------------|
| collinear | Validation utilities | Lightweight, well-chosen |
| Rcpp | C++ bindings | Essential for performance |
| rsample (≥1.0.0) | tidymodels compatibility | Appropriate version pin |
| sf | Spatial data handling | Industry standard |
| future.apply | Parallelization | Modern approach |
| progressr | Progress tracking | Non-intrusive |

### Suggests (6) - Properly Categorized

| Package | Purpose |
|---------|---------|
| future | User-controlled parallelization |
| lwgeom | s2 edge case handling |
| roxyglobals | Documentation generation |
| spelling | Documentation quality |
| testthat (≥3.0.0) | Testing framework |

**Rating: Excellent** - Dependencies are minimal, well-chosen, and properly categorized.

---

## 10. Documentation Quality

### Excellent

- **CLAUDE.md**: Exceptional internal developer guide
- **README.md**: Clear with examples and badges
- **Roxygen documentation**: Complete with @param, @return, @details, @examples

### Missing

- **Vignettes**: No long-form tutorials
- **Package-level docs**: `spatialFolds-package.R` minimal
- **Theory references**: No citation to Roberts et al. 2017 in docs

---

## 11. Recommendations Summary

### Before Release

1. Fix binary search tolerance in `method_contiguous_planar.cpp`
2. Add bounds checking in `method_blocks.cpp`
3. Rename `sf` parameter in `cast_sf_to_bbox()`
4. Add at least one vignette ("Getting Started")

### Post-Release Improvements

5. Add parallel execution tests
6. Expand spherical geometry test coverage
7. Add `@family` tags throughout
8. Standardize `method`/`methods` parameter naming
9. Update complexity documentation in `spatial_thinning.R`
10. Create additional vignettes (spherical geometry, tidymodels integration)

---

## Conclusion

spatialFolds is a well-engineered package with:
- **Strong foundations**: Clean architecture, correct algorithms, modern practices
- **Good test coverage**: ~180 tests verifying behavior
- **Minimal dependencies**: 6 imports, properly categorized

The main improvements needed are:
- Minor bug fixes in C++ code
- Naming consistency refinements
- Documentation expansion (vignettes)
- Test coverage for spherical geometry and parallel execution

The package is **production-ready** with the recommended pre-release fixes applied.
