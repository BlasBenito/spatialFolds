# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Important: ignore the dev/* folder**

## Package Overview

**spatialFolds** is an R package powered by C++ via rcpp to generate training and testing folds for spatial cross-validation using different methods. 

These methods are implemented as simple and fast C++ functions in the folder src/, and the user facing functions calling these methods are in R/

All methods take as input a two column matrix `xy` with longitudes and latitudes, and return a logical vector of the same length as the rows in the input data, where TRUE cases are training samples and FALSE cases are testing samples. 



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
testthat::test_file("tests/testthat/test-lm_model.R")
```

## Core Architecture

- User-facing functions have small signatures and sensible defaults.
- C++ functions assume the input data is validated, and generate a single set of training and testing cases.
- R functions validate the data that goes into C++ functions.

### Methods (src/*)

#### src/method_contiguous.cpp

Implements algorithm to generate contiguous training folds to preserve the spatial structure of the target data:

**Signature**:

```
LogicalVector method_contiguous(
    NumericMatrix xy,
    int center,    #index of buffer center
    double step_x, #growing distance in x axis
    double step_y, #growing distance in y axis
    double target  #records to mark as TRUE
)
```

**Input validation:** Function assumes valid inputs.

**Algorithm:**
1. Starts with small rectangular fold centered on focal point (`center` index)
2. Grows fold incrementally by `step_x` and `step_y`
3. Continues until fold contains `target` records
4. Returns logical vector (TRUE = training, FALSE = testing)

**Key implementation details:**
- Memory-optimized: tracks count without materializing intermediate data
- Uses while loop to grow fold until target training size reached
- Assumes xy matrix has columns "x" (longitude) and "y" (latitude)
- Creates contiguous training regions to preserve spatial structure

**Parameter generation (handled by spatial_folds()):**
- `target` = `training_fraction * nrow(xy)`
- `center` = selected via thinning function (see spatialRF::thinning() and spatialRF::thinning_til_n()). **Placeholder**: random selection until thinning function is implemented
- `step_x` = longitude range / 1000
- `step_y` = latitude range / 1000

#### src/method_random.cpp

Implements a random data-splitting strategy using modern C++ random number generation.

**Signature:**

```
LogicalVector method_random(
    NumericMatrix xy,
    int seed, #random seed
    double target #cases to randomly mark as TRUE
)
```

**Input validation:** Function assumes valid inputs.

**Algorithm:**
1. Creates vector of all indices (0 to n-1)
2. Uses `std::mt19937` random number generator with provided seed
3. Shuffles indices using `std::shuffle` (Fisher-Yates algorithm)
4. Marks first `target` indices as training samples (TRUE)
5. Returns logical vector (TRUE = training, FALSE = testing)

**Key implementation details:**
- Memory-efficient: O(n) space for index vector
- Time complexity: O(n) for shuffling
- Uses modern C++11 `<random>` library (not deprecated `std::random_shuffle`)
- Handles edge cases: target > n (caps at n), target = 0
- Random number generator: `std::mt19937` (Mersenne Twister)
- Assumes xy matrix has columns "x" (longitude) and "y" (latitude)

**Parameter generation (handled by spatial_folds()):**
- `target` = `training_fraction * nrow(xy)`

#### src/method_blocks.cpp

Randomly selects entire grid cells until target count reached. **Optimized**: accepts pre-computed cell assignments to avoid recalculating for each fold iteration.

**Signature:**

```
LogicalVector method_blocks(
    NumericMatrix xy,      #for dimension validation
    IntegerVector cell_id, #pre-computed cell IDs (0-based)
    int seed,              #random seed
    double target          #cases to mark as TRUE
)
```

**Input validation:** Function assumes valid inputs. Validates cell_id length matches nrow(xy).

**Algorithm:**
1. Count points per cell from pre-computed `cell_id` vector (O(n) pass)
2. Determine number of unique cells from max cell_id
3. Shuffle cell IDs using `std::mt19937` (Mersenne Twister)
4. Select cells sequentially until cumulative count >= `target`
5. Mark all points in selected cells as TRUE (O(n) pass)

**Key implementation details:**
- **Critical optimization**: Cell assignment done ONCE in R before loop (via `sf_to_grid()`)
- Memory-efficient: O(C) space where C = number of cells (typically 100-400)
- Time complexity: O(n + C log C) per iteration
- Performance: ~0.001s per iteration on 30k points
- 1.5× faster than approach with per-iteration assignment for 1000 folds
- Uses modern C++11 `<random>` library (`std::mt19937`, `std::shuffle`)
- Handles edge cases: empty cells (skipped), target > n, many empty cells in sparse grids
- Entire blocks are selected (exceeding `target` is acceptable per spec)

**Parameter generation (handled by spatial_folds()):**
- `cell_id` = computed ONCE via `sf_to_grid(sf, grid_rows, grid_columns)` before loop
- `target` = `training_fraction * nrow(xy)`
- Same `cell_id` vector reused across all fold iterations (key optimization)


### User Facing Functions (R/*)

### Generate spatial folds (R/spatial_folds.R)

- Main user-facing function.
- Validates all inputs and provides clear messages, warnings and errors.
- Extracts coordinates from sf dataframe geometry column to create `xy` matrix
- Creates an "iterations dataframe" with all method-specific arguments for each fold
- Calls R/training_mask.R within a future_lapply() loop to let the user parallelize the generation of spatial folds using future::plan()
- Tracks loop progression with progressr (see https://progressr.futureverse.org/ if needed)
- Generates a dataframe with one training/testing vector per column
- Column names include method name and training fraction (e.g., "contiguous_0.75", "random_0.5")

**Signature**:

```
spatial_folds(
  df, #sf dataframe with point geometries
  methods = c("contiguous", "random", "blocks"),
  training_fraction = c(0.75, 0.5), #generates n folds for each fraction
  n = 100, #integer, number of folds per training_fraction
  seed = 1, #integer, random seed for reproducibility
  ... #specific method arguments (if needed)
)
```

**Data flow:**
1. Extracts coordinates from `df` geometry to create numeric matrix `xy` with columns "x" (longitude) and "y" (latitude)
2. For each combination of `method` and `training_fraction`, generates `n` folds
   - Example: 2 methods × 2 fractions × 100 folds = 400 total columns
3. Creates iterations dataframe with one row per fold containing:
   - Method name
   - Training fraction
   - `target` = `training_fraction * nrow(xy)`
   - Method-specific parameters (e.g., `center`, `step_x`, `step_y` for contiguous)
   - Unique seed per iteration (derived from base `seed`)
4. Passes each row to `training_mask()` via `future_lapply()`

### Call C++ method to generate a single training mask (R/training_mask.R)

- Thin R wrapper for C++ methods, intended to be called within a parallelized `future_lapply()` loop (see https://future.apply.futureverse.org/reference/future_lapply.html).
- Assumes all inputs are valid.
- Calls a single C++ method **once**!
- Returns the logical vector.

**Signature**:

```
training_mask(
  xy,
  method = c("contiguous", "random", "blocks"),
  ... #specific method arguments
)
```

### Visualization (R/spatial_fold_plot.R)

**spatial_fold_plot()** provides diagnostic visualization from a logical vector of training (TRUE) and testing (FALSE) cases:

**Features:**
- Plots training (blue) and testing (red) points
- Marks fold center with large black point
- Customizable colors and legend position

### Data Documentation (R/data.R)

Documents example datasets. Add new datasets here with roxygen2 `@format` and `@source` tags.

### Global Variables (R/globals.R)

Auto-generated by roxyglobals roclet. **Never edit manually.** Controlled by DESCRIPTION:
```
Config/roxyglobals/filename: globals.R
Config/roxyglobals/unique: TRUE
```

## Coding Style

1. **Use snake_case consistently** — All functions, arguments, and internal variables use snake_case. No mixing with camelCase or dot.separation.

2. **Organize functions into prefix-based families** — Group related functions under common prefixes that reflect their purpose (`data_*`, `plot_*`, `utils_*`). Users discover functionality through autocomplete.

3. **Provide a main entry point with accessible internals** — One primary function handles the typical workflow; individual steps are exported separately for advanced users.

4. **Maintain consistent parameter names across functions** — When multiple functions share a concept, use identical argument names everywhere.

5. **Delegate parallelization and progress to established packages** — Use `future` for parallel execution and `progressr` for progress bars. Let users configure execution strategy externally.

6. **Use standard R data structures for input and output** — Accept data frames, return data frames, lists, or vectors. Avoid custom S4/R6 classes unless necessary.

## Communication

7. **Lead with code, follow with explanation** — Show code first, keep explanations brief. Avoid lengthy preambles.

8. **Match my technical level without over-explaining** — Skip basic explanations; assume familiarity with R package development tools and focus on the specific problem.

## Workflow

9. **Preserve existing code architecture when making changes** — When fixing bugs or adding features, follow the patterns already established in the codebase. Don't refactor unrelated code or introduce new dependencies unless explicitly requested.

10. **Run devtools::check() and testthat before considering a task complete** — Verify that changes pass R CMD check with no errors or warnings, and that existing tests still pass. Flag any new test failures immediately rather than waiting for me to discover them.

## Documentation System

Uses roxygen2 with roxyglobals roclet:
```r
Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "rd",
    "roxyglobals::global_roclet"))
```

**Best practice:** Run `devtools::document()` twice to ensure NAMESPACE changes propagate properly.

### Required roxygen2 tags
- `@description` — Brief function overview
- `@param` — For each parameter: `(required/optional, type) description. Default: value`
- `@return` — What the function returns
- `@details` — Algorithm details with enumerated steps
- `@examples` — Working examples (use `\dontrun{}` if needed)
- `@export` — For user-facing functions
- `@autoglobal` — For automatic global variable tracking

## Testing

- Tests in `tests/testthat/`
- Uses testthat edition 3 (`Config/testthat/edition: 3`)
- Spelling tests in `tests/spelling.R`
- Run individual test: `testthat::test_file("tests/testthat/test-*.R")`

## Package Dependencies

**Current Imports:**
- None beyond base R

**Suggests:**
- roxyglobals (auto-generate global variable declarations)
- spelling (spell checking)
- testthat (>= 3.0.0)

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

### Memory Optimization
Follow pattern in `training_fold()`:
- Track counts without materializing intermediate data structures
- Use `which()` for index-based operations
- Preallocate vectors when possible: `rep(FALSE, nrow(xy))`

## R Version and Compatibility

- Depends: R (>= 4.1.0)
- LazyData: true with xz compression
- Encoding: UTF-8
