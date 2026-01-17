
<!-- README.md is generated from README.Rmd. Please edit that file -->

# spatialFolds <a href="https://blasbenito.github.io/spatialFolds/"><img src="man/figures/logo.png" align="right" height="138" alt="spatialFolds website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

The R package **spatialFolds** provides fast tools for spatial
data-splitting and spatial thinning, powered by C++ via Rcpp. It
introduces a novel contiguous method that preserves spatial structure by
growing rectangular folds from well-distributed center points.

## Summary

- [**Spatial cross-validation**](#spatial-cross-validation): Generate
  training/testing folds with three methods:

  - **contiguous**: rectangle-growing from distributed centers to
    preserve spatial structure  
  - **blocks**: grid-based selection
  - **random** traditional random splitting with no spatial structure.

- [**Spatial thinning**](#spatial-thinning): Reduce point density to a
  minimum distance or target count using efficient grid-based spatial
  indexing.

- [**tidymodels integration**](#tidymodels-integration): Functions
  `spatial_contiguous_cv()` and `spatial_blocks_cv()` return
  rsample-compatible objects for seamless use with
  `tune::fit_resamples()`.

- [**C++ performance**](#): Core algorithms implemented in C++ with
  binary search optimization and grid-based indexing for fast execution
  on large datasets.

- [**Flexible parallelization**](#setup): R function \[spatial_folds()\]
  has built-in support for parallel execution via `future` and progress
  tracking via `progressr`.

## Install

Install **spatialFolds** from GitHub:

``` r
remotes::install_github(
  repo = "blasbenito/spatialFolds",
  ref = "main"
)
```

## Getting Started

### Setup

``` r
library(spatialFolds)
```

Enable parallelization with `future`:

``` r
library(future)
future::plan("multisession", workers = 4)
```

Enable progress bars with `progressr` (does not work in Rmarkdown):

``` r
progressr::handlers(global = TRUE)
```

### Example Data

The package includes a dataset with 30,000 point locations for testing:

``` r
data(xy_sf)
head(xy_sf, 10)
#>    id         geometry
#> 1   1 -162.704, 55.112
#> 2   2 -161.988, 60.912
#> 3   3 -161.829, 60.321
#> 4   4 -160.404, 56.121
#> 5   5 -160.046, 59.096
#> 6   6 -159.688, 61.887
#> 7   7 -158.296, 57.246
#> 8   8 -158.254, 56.629
#> 9   9 -157.329, 58.454
#> 10 10 -157.304, 59.979
```

### Spatial Cross-Validation

The `spatial_folds()` function generates training/testing folds using
different spatial strategies.

The **contiguous** method creates spatially coherent training folds by
growing rectangles from well-distributed center points:

``` r
folds <- spatial_folds(
  df = xy_sf,
  methods = "contiguous",
  training_fraction = 0.75,
  n = 5, #number of repetitions
  seed = 1
)
#> spatialFolds::spatial_folds(): Generated 5 folds (1 methods x 1 training fractions x 5 iterations)
```

The result is a data frame with logical columns where `TRUE` indicates
training samples and `FALSE` indicates testing samples:

``` r
dim(folds)
#> [1] 30000     5
names(folds)
#> [1] "contiguous_0.75_1" "contiguous_0.75_2" "contiguous_0.75_3"
#> [4] "contiguous_0.75_4" "contiguous_0.75_5"
```

Visualize the spatial structure of a fold:

``` r
spatial_fold_plot(
  df = xy_sf,
  training_fold = folds$contiguous_0.75_1
)
```

<img src="man/figures/README-fold-plot-1.png" alt="" width="100%" />

The contiguous method preserves spatial clustering in the training set,
which is important for evaluating models where spatial autocorrelation
affects predictions.

**Other methods** available:

- `"blocks"`: Randomly selects entire grid cells until the training
  fraction is reached. Useful when spatial heterogeneity follows a grid
  pattern.
- `"random"`: Traditional random splitting without spatial structure.
  Provides a baseline comparison.

### tidymodels Integration

For direct integration with tidymodels workflows, use
`spatial_contiguous_cv()`:

``` r
cv_folds <- spatial_contiguous_cv(
  data = xy_sf,
  v = 5,
  prop = 0.8,
  seed = 123
)

cv_folds
#> # Manual resampling 
#> # A tibble: 5 × 2
#>   splits               id   
#>   <list>               <chr>
#> 1 <split [24001/5999]> Fold1
#> 2 <split [24003/5997]> Fold2
#> 3 <split [24000/6000]> Fold3
#> 4 <split [24003/5997]> Fold4
#> 5 <split [24001/5999]> Fold5
```

This returns an `rset` object compatible with `tune::fit_resamples()`
and other tidymodels functions:

``` r
library(tune)
library(parsnip)
library(workflows)

# Define model and workflow
model <- linear_reg() |> set_engine("lm")
wf <- workflow() |> add_model(model) |> add_formula(y ~ x)

# Fit with spatial cross-validation
results <- fit_resamples(wf, resamples = cv_folds)
```

Similarly, `spatial_blocks_cv()` provides block-based spatial
cross-validation with the same tidymodels compatibility.

### Spatial Thinning

The `spatial_thinning()` function reduces point density while
maintaining spatial coverage:

``` r
# Thin to approximately 500 points
thinned <- spatial_thinning(
  df = xy_sf,
  method = "target",
  target = 500
)
#> spatialFolds::spatial_thinning(): Thinned from 30000 to 459 points (1.5% retained)

nrow(thinned)
#> [1] 459
```

Visualize the thinning result:

``` r
par(mfrow = c(1, 2))

# Original data
plot(
  sf::st_coordinates(xy_sf),
  pch = 16,
  cex = 0.3,
  col = "gray50",
  main = paste("Original:", nrow(xy_sf), "points"),
  xlab = "x",
  ylab = "y"
)

# Thinned data
plot(
  sf::st_coordinates(thinned),
  pch = 16,
  cex = 0.8,
  col = "blue3",
  main = paste("Thinned:", nrow(thinned), "points"),
  xlab = "x",
  ylab = "y"
)
```

<img src="man/figures/README-thinning-plot-1.png" alt="" width="100%" />

Use `method = "distance"` to enforce a fixed minimum distance between
points:

``` r
# Thin using minimum distance
thinned_distance <- spatial_thinning(
  df = xy_sf,
  method = "distance",
  distance = 5
)
```

Use cases for spatial thinning include:

- Reducing pseudo-replication from clustered sampling
- Generating well-distributed center points for spatial cross-validation
- Subsampling large datasets while preserving spatial coverage

## Citation

If you find this package useful, please cite it:

``` r
citation("spatialFolds")
```

## Support

- Report bugs or request features: [GitHub
  Issues](https://github.com/blasbenito/spatialFolds/issues)
- Package documentation: [pkgdown
  site](https://blasbenito.github.io/spatialFolds/)
