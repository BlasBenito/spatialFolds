# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Important: ignore the dev/* folder**

## Package Overview

**spatialFolds**: R package powered by C++ via rcpp to generate training and testing folds for spatial cross-validation and apply spatial thinning using different methods. 

These methods are implemented as simple and fast C++ functions in the folder src/, and the user facing functions calling these methods are in R/

All low level methods take as input a two column matrix `xy` with longitudes and latitudes, while high-level methods take sf data frames.


## Essential Development Commands

```r
# Load package for interactive testing
devtools::load_all()

# Update documentation
devtools::document()

# Run checks
devtools::check()

# Run tests
devtools::test()

# Run single test file
testthat::test_file("tests/testthat/test-....R")
```

## Core Architecture

- User-facing functions have small signatures and sensible defaults.
- C++ functions assume the input data is validated
- R functions validate the data that goes into C++ functions.

### C++ functions (src/*)

- src/method_contiguous.cpp: generates contiguous training folds to preserve the spatial structure of the target data.

- src/method_random.cpp: random data-splitting strategy using modern C++ random number generation.

- src/method_blocks.cpp: randomly selects entire grid cells until target count reached. 

- src/thinning_to_distance.cpp: distance-based sequential spatial thinning with grid-based spatial indexing.

- src/thinning_to_target.cpp: sequential spatial thinning with grid-based spatial indexing until a target count is reached.

### User Facing Functions (R/*)

- R/spatial_folds.R: 
   - Validates inputs
   - Calls R/training_mask.R within a future_lapply() loop to let the user parallelize the generation of spatial folds using future::plan()
   - Tracks loop progression with progressr (see https://progressr.futureverse.org/ if needed)
   - Generates a dataframe with one training/testing vector per column
   - Column names include method name and training fraction (e.g., "contiguous_0.75", "random_0.5")

- R/spatial_fold_plot.R: provides diagnostic visualization from a logical vector of training (TRUE) and testing (FALSE) cases.

- R/validate_arg_sf.R: internal function that validates sf/data.frame inputs and extracts xy coordinates. Used by spatial_folds() and spatial_thinning().

- R/data.R: data documentation of example datasets in data/ folder

- **`xy_matrix`**: Matrix with 30k pairs of coordinates, columns "x" and "y"
  - Use for testing C++ functions
  - Load with `data(xy_matrix)`

- **`xy_sf`**: Sf dataframe with 30k point, columns "id" and "geometry"
  - Use for testing R functions that accept sf dataframes
  - Load with `data(xy_sf)`` or access directly in tests`

**Important for testing**: Always use these example datasets in test files (`tests/testthat/*.R`) to ensure consistent test data across the package.

## Coding Style

1. **Use snake_case consistently** — All functions, arguments, and internal variables use snake_case. No mixing with camelCase or dot.separation.

2. **Organize functions into prefix-based families** — Group related functions under common prefixes that reflect their purpose (`data_*`, `plot_*`, `utils_*`). Users discover functionality through autocomplete.

3. **Provide a main entry point with accessible internals** — One primary function handles the typical workflow; individual steps are exported separately for advanced users.

4. **Maintain consistent parameter names across functions** — When multiple functions share a concept, use identical argument names everywhere.

5. **Delegate parallelization and progress to established packages** — Use `future` for parallel execution and `progressr` for progress bars. Let users configure execution strategy externally.

6. **Use standard R data structures for input and output** — Accept data frames, return data frames, lists, or vectors. Avoid custom S4/R6 classes unless necessary.

## Workflow

9. **Preserve existing code architecture when making changes** — When fixing bugs or adding features, follow the patterns already established in the codebase. Don't refactor unrelated code or introduce new dependencies unless explicitly requested.

10. **Run the test file immediately after modifying a function** — After editing any R or C++ function, run its corresponding test file with `devtools::test_file("tests/testthat/test-<function_name>.R")` to catch regressions early.

11. **Run devtools::check() and testthat before considering a task complete** — Verify that changes pass R CMD check with no errors or warnings, and that existing tests still pass. Flag any new test failures immediately rather than waiting for me to discover them.

## Documentation System

**Best practice:** Run `devtools::document()` twice to ensure NAMESPACE changes propagate properly.

### Required roxygen2 tags
- `@description` — Brief function overview
- `@param` — For each parameter: `(required/optional, type) description. Default: value`
- `@return` — What the function returns
- `@details` — Algorithm details with enumerated steps
- `@examples` — Working examples (use `\dontrun{}` if needed)
- `@family` — Tag to group functions in the reference page of the packages website
- `@export` — For user-facing functions
- `@autoglobal` — For automatic global variable tracking

## Testing

- Tests in `tests/testthat/`
- Uses testthat edition 3 (`Config/testthat/edition: 3`)
- Spelling tests in `tests/spelling.R`
- Run individual test: `testthat::test_file("tests/testthat/test-*.R")`

## Testing Philosophy

**Core principles:**
- Every test must be able to fail when the code is broken
- Tests must verify behavior, not just type/structure
- Ask: "Would this test still pass if I replaced the function body with a hardcoded return?"

**Required elements for each test file:**
1. **Behavior verification** - Test what the function *does*, not just what it *returns*
2. **Edge cases** - Empty input, single element, boundary conditions
3. **Reproducibility** - Same seed = same result (for random functions)
4. **Algorithm-specific checks** - Verify the core algorithm property

**Banned patterns:**
- `expect_true(is.logical(x))` alone without behavior checks
- `expect_no_error()` without verifying the result
- Tests that only check output dimensions
- `expect_true(sum(x) >= target)` without verifying HOW the target was reached

**Good test patterns:**
```r
# Verify reproducibility (random functions)
result1 <- method_random(xy, seed = 1, target = 100)
result2 <- method_random(xy, seed = 1, target = 100)
expect_identical(result1, result2)

# Verify different inputs produce different outputs
result3 <- method_random(xy, seed = 999, target = 100)
expect_false(identical(result1, result3))

# Verify algorithm property (e.g., blocks selected as units)
for (block in unique(block_id)) {
  mask <- block_id == block
  expect_true(all(result[mask]) || !any(result[mask]))
}

# Verify exact count (not just >=)
expect_equal(sum(result), expected_count)

# Verify geometry property (contiguous rectangle)
selected_x <- xy[result, "x"]
expect_true(all(selected_x >= min_x & selected_x <= max_x))
```

## Package Dependencies

**Adding dependencies:** Add new function dependencies to `Imports:` in DESCRIPTION. Use `Suggests:` for development-only or optional packages.

## Common Patterns

### Rcpp/C++ Patterns

**Standard includes:**
```cpp
#include <Rcpp.h>
#include <algorithm>  // for std::shuffle, std::max, etc.
#include <random>     // for std::mt19937, modern RNG
#include <vector>     // for std::vector
using namespace Rcpp;
```

**Random number generation:**
```cpp
// Use modern C++11 random library, not deprecated std::random_shuffle
std::mt19937 rng(seed);
std::shuffle(indices.begin(), indices.end(), rng);
```

**Type conversion:**
```cpp
// Convert double to int when needed
int target_int = static_cast<int>(target);
```

**Index conversion:**
```cpp
// R uses 1-based indexing, C++ uses 0-based
int center_idx = center - 1;
```

**Vector operations:**
```cpp
// Extract columns from NumericMatrix
NumericVector x_coords = xy(_, 0);  // all rows, first column
NumericVector y_coords = xy(_, 1);  // all rows, second column

// Initialize LogicalVector
LogicalVector result(n, false);  // n elements, all FALSE
```

**Memory efficiency:**
```cpp
// Use std::vector for index operations
std::vector<int> indices(n);
for (int i = 0; i < n; i++) {
  indices[i] = i;
}
```

**Documentation in C++:**
- Use roxygen2 format directly in C++ files
- Marker: `// [[Rcpp::export]]` to export to R
- Documentation goes in comments before function: `//'`
- After `devtools::load_all()`, Rcpp auto-generates R wrappers in `R/RcppExports.R`

**Compilation workflow:**
1. Write/modify `.cpp` file in `src/`
2. Run `devtools::load_all()` - compiles and generates R wrappers
3. Run `devtools::document()` twice - generates `.Rd` files and updates NAMESPACE
4. Function is now available for testing

### Matrix Handling
- Assume xy matrix has columns "x" and "y"
- Use matrix indexing: `xy[, "x"]` and `xy[, "y"]`
- Set colnames explicitly when needed: `colnames(xy) <- c("x", "y")`

### Input Validation Pattern
```r
if (!is.logical(training_fold)) {
  stop(
    "spatialFolds::function_name(): argument 'arg' must be of type `logical`.",
    call. = FALSE
  )
}
```

Always prefix messages, warnings, and error messages with `package::function()` for user clarity.

### Unified Input Validation

Use `validate_arg_sf()` for validating sf/data.frame inputs in user-facing functions:

```r
validated <- validate_arg_sf(
  df = df,
  function_name = "my_function",
  min_rows = 10L,
  check_coord_range = TRUE
)
df <- validated$df
xy <- validated$xy
input_is_sf <- validated$input_is_sf
```

The `function_name` parameter ensures consistent error messages like `"spatialFolds::my_function(): ..."`.

### sf/s2 Geometry Handling

**Degenerate geometries** (single point, all points at same location) can cause issues with s2 spherical geometry. When testing edge cases:

```r
# Temporarily disable s2 with proper cleanup
s2_was_enabled <- sf::sf_use_s2()
sf::sf_use_s2(FALSE)
on.exit(sf::sf_use_s2(s2_was_enabled), add = TRUE)
```

**lwgeom dependency**: When s2 is disabled, `sf::st_area()` requires lwgeom. Always check before calling:

```r
if (!sf::sf_use_s2() && !requireNamespace("lwgeom", quietly = TRUE)) {
  stop(
    "spatialFolds::my_function(): Package 'lwgeom' is required when s2 is disabled. ",
    "Please install it with: install.packages('lwgeom')",
    call. = FALSE
  )
}
```
