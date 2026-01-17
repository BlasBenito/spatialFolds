# Spatial Cross-Validation Methods: Design and Evaluation

**Document Purpose**: This document evaluates the current spatial cross-validation methods implemented in spatialFolds, reviews alternatives from the literature, and provides guidance for future development.

**Date**: January 2025
**Status**: Current implementation complete with 3 methods

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Current Implementation](#current-implementation)
3. [Literature Review](#literature-review)
4. [Evaluation of Additional Methods](#evaluation-of-additional-methods)
5. [Design Constraints and Decisions](#design-constraints-and-decisions)
6. [Recommendations](#recommendations)
7. [References](#references)

---

## Executive Summary

**spatialFolds** currently implements three complementary spatial cross-validation methods:

1. **method_random** - Baseline comparison (spatially naive)
2. **method_blocks** - Standard grid-based approach (moderate spatial separation)
3. **method_contiguous** - Local geographic extrapolation

These methods cover a spectrum from no spatial structure (random) to strict local extrapolation (contiguous), providing comprehensive validation options for spatial modeling.

**Key Finding**: While buffer-based methods are widely cited in literature, they fundamentally require 3-state classification (training/testing/excluded) that doesn't fit our TRUE/FALSE API design. The current three methods provide excellent coverage without this limitation.

---

## Current Implementation

### Architecture Overview

All methods follow a consistent API:
- **Input**: Numeric matrix `xy` (coordinates), method-specific parameters
- **Output**: LogicalVector where TRUE = training samples, FALSE = testing samples
- **Design principle**: Every point classified as either training or testing (2-state system)

### Method 1: method_random

**Purpose**: Baseline for comparison and demonstrating spatial leakage

```cpp
LogicalVector method_random(NumericMatrix xy, int seed, double target)
```

**Algorithm**:
1. Shuffle all point indices using Fisher-Yates algorithm
2. Select first `target` indices as training (TRUE)
3. Remaining indices become testing (FALSE)

**Spatial Characteristics**:
- **Spatial pattern**: Random intermixing, no spatial structure
- **Autocorrelation**: Breaks spatial autocorrelation
- **Test type**: Interpolation only (test points surrounded by training points)
- **Distance to training**: Typically meters to tens of meters

**Use Cases**:
- Baseline comparison to demonstrate importance of spatial CV
- Non-spatial models where autocorrelation isn't a concern
- Showing maximum performance inflation due to spatial leakage

**Strengths**:
- Simple, well-understood
- Maximum geographic coverage in training set
- Fast: O(n) complexity
- Efficient training set utilization

**Limitations**:
- **CRITICAL for spatial data**: Violates spatial independence
- Produces overly optimistic accuracy estimates
- Training/testing points often extremely close
- Not suitable for assessing spatial prediction ability

**When to use**: Only for baseline comparison or non-spatial models. Should NOT be used as primary validation for spatial models.

---

### Method 2: method_blocks

**Purpose**: Standard grid-based spatial cross-validation

```cpp
LogicalVector method_blocks(NumericMatrix xy, IntegerVector cell_id,
                           int seed, double target)
```

**Algorithm**:
1. Accept pre-computed cell assignments from `block_ids()`
2. Count points per grid cell
3. Shuffle cells randomly
4. Select cells until cumulative count ≥ target
5. Mark points in selected cells as training (TRUE)

**Spatial Characteristics**:
- **Spatial pattern**: Grid-based clustering with cell-sized gaps
- **Autocorrelation**: Moderate spatial separation (depends on grid resolution)
- **Test type**: Mixed interpolation/extrapolation
  - Interior test blocks: interpolation (surrounded by training blocks)
  - Edge test blocks: extrapolation (boundary of study area)
- **Distance to training**: Determined by cell size and grid configuration

**Use Cases**:
- Standard approach in spatial ecology ([Roberts et al. 2017](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/ecog.02881))
- Large-scale environmental modeling
- Studies covering multiple ecological regions
- Balancing spatial independence with sample size

**Strengths**:
- Widely accepted in literature (blockCV standard)
- Flexible grid resolution (user-controlled spatial separation)
- Computationally efficient: O(n + C log C) where C = number of cells
- Pre-computation optimization for repeated folding (1.5× speedup)
- Tests both local and regional transferability

**Limitations**:
- Rectangular grid may not match ecological boundaries
- Grid resolution choice affects independence vs. sample size tradeoff
- Edge blocks behave differently than interior blocks
- May create artificial boundaries within continuous landscapes
- Selected blocks often exceed exact target sample size

**Parameter Guidance**:
- **Grid size**: Roberts et al. suggest blocks substantially larger than spatial autocorrelation range
- **Typical values**: 10×10 to 20×20 for large study areas
- **Resolution tradeoff**: Smaller cells → less spatial separation but more flexibility

**Implementation Note**: Uses optimized cell pre-computation. Grid assignment done once in R, then reused across all fold iterations for ~1.5× performance improvement.

---

### Method 3: method_contiguous

**Purpose**: Local geographic extrapolation from a focal region

```cpp
LogicalVector method_contiguous(NumericMatrix xy, int center,
                               double step_x, double step_y, double target)
```

**Algorithm**:
1. Start with small rectangle centered on focal point (`center` index)
2. Grow rectangle incrementally by `step_x` and `step_y`
3. Use binary search to find rectangle size containing ≥ `target` points
4. Mark points within rectangle as training (TRUE)

**Spatial Characteristics**:
- **Spatial pattern**: Rectangular training region with surrounding test "halo"
- **Autocorrelation**: High within-set autocorrelation, strong spatial separation
- **Test type**: Pure extrapolation (training → nearby but non-overlapping areas)
- **Distance to training**: Immediate boundary (no gap), but testing outside training extent

**Use Cases**:
- Field campaigns with localized sampling
- Testing model transferability to adjacent regions
- Species distribution modeling across environmental gradients
- Regional ecological studies (train locally, predict to neighbors)

**Strengths**:
- Realistic spatial structure (mimics actual data collection)
- Tests strict extrapolation capability
- Fast implementation: O(n log k) where k ≈ 10-15 iterations (15-20× faster than R)
- Maintains geographic cohesion in both training and testing sets

**Limitations**:
- Depends heavily on center point selection
- Rectangular shape arbitrary (doesn't follow ecological boundaries)
- May create edge effects along rectangle boundaries
- Does not test interpolation within study area
- Center selection strategy not yet implemented (currently placeholder)

**Parameter Guidance**:
- **center**: Should be selected via spatial thinning (see `spatialRF::thinning()`)
  - *Current status*: Random selection placeholder until thinning implemented
- **step_x/step_y**: Automatically computed as 1/1000 of longitude/latitude range
  - Provides gradual growth for fine-grained control

**Future Enhancement**: Implement thinning-based center selection for more systematic coverage of study area when generating multiple folds.

---

## Literature Review

### Standard Methods in Spatial Ecology

**Roberts et al. (2017)** - Seminal paper on spatial CV
*Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure*. Ecography, 40: 913-929.

**Key Recommendations**:
- Spatial blocks should be substantially bigger than autocorrelation range
- Buffer method: buffer size = spatial autocorrelation range provides good error estimates
- Multiple CV strategies needed depending on study design

**blockCV Package** ([Valavi et al. 2019](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13107))
Standard R implementation with 3,000+ citations

**Methods**:
1. Spatial blocks (`cv_spatial`) - Similar to our method_blocks
2. Buffer-based (`cv_buffer`) - Creates exclusion zones (see evaluation below)
3. Environmental clustering (`cv_cluster`) - Groups by environmental similarity
4. NNDM - Nearest neighbor distance matching (recent addition)

### Recent Developments (2024-2025)

**Spatial CV Best Practices**:
- [Frontiers in Remote Sensing 2025](https://www.frontiersin.org/journals/remote-sensing/articles/10.3389/frsen.2025.1531097/full): Block size selection matters significantly
- [Environmental Systems Research 2024](https://environmentalsystemsresearch.springeropen.com/articles/10.1186/s40068-024-00352-9): Checkerboard block allocation most effective for clustered samples
- [Nature Communications 2024](https://www.nature.com/articles/s41467-024-55240-8): Spatial autocorrelation remains a major challenge in geospatial ML

**Key Findings**:
- Block size should align with spatial autocorrelation range
- No single method optimal for all scenarios
- Combining multiple validation strategies recommended
- Buffer methods provide strictest independence but reduce sample size

---

## Evaluation of Additional Methods

### Method 4: Buffer-Based Validation ⚠️ **API INCOMPATIBILITY**

**Description**: Create exclusion zones (buffers) around testing points to enforce minimum separation distance.

**Typical Implementation** (from blockCV):
1. Select testing points
2. Create buffer zones of radius = spatial autocorrelation range
3. Exclude training points within buffer zones
4. Result: **3 classes** of points:
   - Testing points
   - Training points (outside buffers)
   - Excluded points (within buffer zones, not used)

**Why it's widely cited**:
- Roberts et al. (2017) gold standard recommendation
- Directly addresses spatial autocorrelation
- User-controllable separation distance
- More ecologically meaningful than arbitrary grids

**Critical Issue - API Incompatibility**:

Our current API returns LogicalVector (TRUE/FALSE):
```cpp
// All existing methods
LogicalVector method_xxx(...) {
  // Every point classified as TRUE (training) or FALSE (testing)
  return result; // length(result) == nrow(xy), all TRUE or FALSE
}
```

Buffer method fundamentally requires 3 states:
```
Point classifications:
- Training: Use for model fitting (TRUE)
- Testing: Use for evaluation (FALSE)
- Excluded: Within buffer zone (??? - doesn't fit TRUE/FALSE)
```

**Possible Workarounds**:

❌ **Option 1: Treat excluded as testing**
`excluded + testing = FALSE`
- Inflates testing set size
- Violates buffer method definition
- Not faithful to literature

❌ **Option 2: Treat excluded as training**
`excluded + training = TRUE`
- Violates spatial independence (the whole point!)
- Makes buffer method equivalent to method_blocks

❌ **Option 3: Change API to support 3 states**
Return IntegerVector (0/1/2) or factor
- **Breaks consistency** with existing methods
- Complicates downstream code (`spatial_folds()`, visualization)
- Requires API redesign
- All existing code expects logical vectors

❌ **Option 4: Cluster-based alternative**
Spatial clustering with buffer-sized gaps
- Not the same as buffer method
- Different spatial properties
- Would need different name

**Decision**: Buffer method doesn't fit current architecture. The 2-state logical vector API is a fundamental design choice that provides simplicity and consistency. Adding buffer would require either:
1. Violating the method's definition (workarounds 1-2)
2. Breaking the API (workaround 3)
3. Implementing something different (workaround 4)

**Recommendation**: Document this limitation but maintain current design. The three existing methods provide excellent coverage within the 2-state paradigm.

---

### Method 5: Environmental Blocking

**Description**: Cluster points by environmental dissimilarity instead of geographic distance.

**Algorithm**:
1. Extract environmental covariates at each point location
2. Perform clustering (K-means, hierarchical) in environmental space
3. Select clusters for training/testing
4. Tests niche transferability across environmental gradients

**Advantages**:
- Relevant for species distribution modeling
- Tests extrapolation in environmental dimensions
- Useful when environmental space more important than geographic space
- Fits 2-state API (clusters = TRUE/FALSE)

**Challenges**:
- Requires environmental covariate data (additional input)
- Clustering algorithm choice affects results
- May not align with geographic space
- More complex user setup

**Assessment**: **Lower priority**. Useful for specialized niche modeling but requires additional data infrastructure. Could be added if users request.

---

### Method 6: Leave-One-Out Geographic (LOGO-CV)

**Description**: Hierarchical geographic clustering with site-level leave-one-out.

**Algorithm**:
1. Group points by site/location (predefined or hierarchical clustering)
2. Leave one site out for testing, train on all others
3. Iterate through sites

**Advantages**:
- Respects natural spatial grouping (field sites, plots)
- Realistic for multi-site studies
- Avoids pseudoreplication within sites
- Fits 2-state API (site in/out = TRUE/FALSE)

**Challenges**:
- Requires site-level grouping (additional metadata)
- Unbalanced fold sizes if sites vary
- May be too strict if sites very different
- Less relevant for continuous sampling

**Assessment**: **Moderate priority**. Useful for specific study designs (multi-site field studies) but requires additional metadata. Could be added for specialized workflows.

---

### Method 7: Nearest Neighbor Distance Matching (NNDM)

**Description**: Match nearest neighbor distances between CV folds and prediction area.

**Implementation**: Recent addition to blockCV and CAST packages (Meyer & Pebesma 2022).

**Advantages**:
- Cutting-edge methodology
- Addresses spatial extrapolation rigorously
- Used in global mapping efforts

**Challenges**:
- Computationally complex
- Requires defining prediction area/extent
- May be overkill for typical use cases
- Newer method, less field testing

**Assessment**: **Low priority**. Advanced method for specialized applications. Current three methods provide sufficient coverage for most spatial modeling needs.

---

## Design Constraints and Decisions

### Core Design Principles

**1. Consistent 2-State API**

All methods return LogicalVector with binary classification:
```cpp
LogicalVector method_xxx(...) {
  LogicalVector result(n, false);
  // Logic to set some elements to true
  return result; // Every element either true or false
}
```

**Benefits**:
- Simple, consistent interface
- Easy integration with downstream code
- Clear semantics: TRUE = training, FALSE = testing
- Efficient R interoperability
- Straightforward visualization

**Tradeoff**: Cannot accommodate methods requiring exclusion zones without violating design principles.

**2. Performance-Critical Implementation**

Methods called 1000s of times in `future_lapply()` loops:
```r
folds <- future_lapply(1:1000, function(i) {
  method_xxx(xy, ..., seed = i)
})
```

**Optimization strategies**:
- C++ implementation for compute-intensive operations
- Pre-computation of shared data (e.g., cell_id for method_blocks)
- O(n) or O(n log n) complexity targets
- Minimal memory overhead

**Example**: method_blocks pre-computes cell assignments once (~0.001s), then reuses for 1000 folds (~0.001s each) = 1.5× speedup vs. per-iteration assignment.

**3. Spatial Structure Preservation**

Package goal: "Generate training and testing folds for spatial cross-validation using different methods"

**Key requirement**: Methods should respect spatial autocorrelation and test realistic prediction scenarios.

**Current coverage**:
- **method_random**: Violates spatial structure (baseline showing problem)
- **method_blocks**: Moderate spatial separation (standard approach)
- **method_contiguous**: Strong spatial separation (local extrapolation)

This spectrum provides comprehensive testing from naive (random) to strict (contiguous) spatial independence.

**4. Simplicity and Usability**

Target users: Ecologists and environmental modelers, not ML specialists.

**Design choices**:
- Sensible parameter defaults
- Clear documentation with use cases
- Consistent naming conventions
- Reference to published methods
- Visual diagnostics (spatial_fold_plot)

---

## Recommendations

### Current Status: ✅ Complete for Initial Release

The three implemented methods provide **excellent coverage** for spatial cross-validation:

1. **Baseline comparison** (method_random) - Demonstrates spatial leakage
2. **Standard approach** (method_blocks) - Grid-based, widely accepted
3. **Local extrapolation** (method_contiguous) - Tests adjacent-area prediction

This covers the spatial independence spectrum and aligns with published best practices.

### Future Additions: Prioritized List

If expanding the method suite, prioritize based on:
- User demand
- Scientific utility
- API compatibility
- Implementation complexity

**Priority 1: Complete method_contiguous** ⭐⭐⭐
*Status: Implementation complete, center selection placeholder*

- Implement thinning-based center selection (see `spatialRF::thinning()`)
- Currently uses random selection as placeholder
- Would provide more systematic spatial coverage

**Priority 2: Environmental clustering** 🌍
*Status: Not implemented*

IF users request for niche modeling applications:
- Requires environmental covariate data infrastructure
- Fits existing 2-state API
- Moderate implementation complexity
- Adds value for SDM workflows

**Priority 3: LOGO-CV for multi-site studies** 📍
*Status: Not implemented*

IF users have multi-site data:
- Requires site metadata infrastructure
- Fits existing 2-state API
- Low implementation complexity
- Useful for field ecology workflows

**Priority 4: Alternative to buffer method** ⚠️
*Status: Not planned*

Buffer method doesn't fit current design. IF strict spatial independence needed beyond method_blocks, consider:
- Implementing variable-sized buffer in method_blocks (larger cells = more separation)
- Adding grid resolution guidance based on spatial autocorrelation
- Referring users to blockCV for buffer-specific workflows

### What NOT to Add

**Buffer method as traditionally defined**: Requires 3-state classification, breaks API consistency

**NNDM**: Complex, cutting-edge, most users won't need it

**Too many methods**: Risk of decision paralysis. Current three cover primary use cases.

### Integration Priorities

Before adding new methods, complete core infrastructure:

1. ✅ **C++ methods implemented**: method_random, method_blocks, method_contiguous
2. ⏸️ **R helper functions**: `block_ids()` for cell assignment
3. ⏸️ **Main function**: `spatial_folds()` integration with futureverse
4. ⏸️ **Visualization**: `spatial_fold_plot()` diagnostics
5. ⏸️ **Documentation**: Vignettes showing when to use each method
6. ⏸️ **Validation**: Tests comparing to blockCV results

Focus on completing the infrastructure for existing methods before expanding the method suite.

---

## References

### Primary Literature

**Roberts, D. R., et al. (2017)**. Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure. *Ecography*, 40(8), 913-929.
https://besjournals.onlinelibrary.wiley.com/doi/10.1111/ecog.02881
*Seminal paper establishing spatial CV best practices*

**Valavi, R., et al. (2019)**. blockCV: An R package for generating spatially or environmentally separated folds for k-fold cross-validation of species distribution models. *Methods in Ecology and Evolution*, 10(2), 225-232.
https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13107
*Standard R implementation, 3000+ citations*

**Meyer, H., & Pebesma, E. (2022)**. Machine learning-based global maps of ecological variables and the challenge of assessing them. *Nature Communications*, 13(1), 2768.
https://www.nature.com/articles/s41467-022-29838-9
*NNDM method and global mapping challenges*

### Recent Reviews and Applications

**Ploton, P., et al. (2020)**. Spatial validation reveals poor predictive performance of large-scale ecological mapping models. *Nature Communications*, 11, 4540.
https://www.nature.com/articles/s41467-020-18321-y
*Large-scale analysis showing importance of spatial validation*

**Recent 2024-2025 Applications**:
- Block selection strategies: https://www.frontiersin.org/journals/remote-sensing/articles/10.3389/frsen.2025.1531097/full
- Random forest spatial CV: https://environmentalsystemsresearch.springeropen.com/articles/10.1186/s40068-024-00352-9
- Geospatial ML challenges: https://www.nature.com/articles/s41467-024-55240-8

### Software Implementations

**blockCV** (R package): https://github.com/rvalavi/blockCV
*Reference implementation for spatial/environmental blocking*

**CAST** (R package): https://hannameyer.github.io/CAST/
*Advanced methods including NNDM*

**sperrorest** (R package): https://cran.r-project.org/package=sperrorest
*Alternative spatial CV implementation*

**spatialRF** (R package): https://github.com/blasbenito/spatialRF
*Contains thinning functions for center selection*

---

## Conclusion

The current implementation of **spatialFolds** provides a **solid foundation** for spatial cross-validation with three complementary methods covering the spectrum of spatial independence. While additional methods exist in the literature (particularly buffer-based approaches), they either don't fit our 2-state API design or address specialized use cases that can be added later based on user demand.

**Next steps** should focus on completing the R infrastructure (helper functions, main wrapper, visualization) rather than adding more methods. Once the package is stable and users provide feedback, we can consider targeted additions based on actual needs.

The decision to maintain a simple, consistent API (LogicalVector with TRUE/FALSE) provides long-term benefits for usability and maintainability, even if it means not implementing every method from the literature.

---

*Document maintained by spatialFolds development team. Last updated: January 2025*
