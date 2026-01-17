# Tests for fold_to_rsplit function
test_that("fold_to_rsplit creates valid rsplit object", {
  # Create simple test data
  test_data <- data.frame(
    x = 1:10,
    y = 11:20
  )

  # Create fold vector (first 7 training, last 3 testing)
  fold <- c(rep(TRUE, 7), rep(FALSE, 3))

  # Create rsplit (internal function, accessed via :::)
  split <- spatialFolds:::fold_to_rsplit(fold = fold, data = test_data)

  # Check class

  expect_s3_class(split, "rsplit")

  # Check analysis (training) indices
  analysis_idx <- rsample::analysis(split)
  expect_equal(nrow(analysis_idx), 7)
  expect_equal(analysis_idx$x, 1:7)

  # Check assessment (testing) indices
  assessment_idx <- rsample::assessment(split)
  expect_equal(nrow(assessment_idx), 3)
  expect_equal(assessment_idx$x, 8:10)
})

test_that("fold_to_rsplit handles edge cases", {
  test_data <- data.frame(x = 1:5, y = 6:10)

  # Almost all training
  fold_mostly_train <- c(TRUE, TRUE, TRUE, TRUE, FALSE)
  split <- spatialFolds:::fold_to_rsplit(fold = fold_mostly_train, data = test_data)

  expect_equal(nrow(rsample::analysis(split)), 4)
  expect_equal(nrow(rsample::assessment(split)), 1)

  # Almost all testing
  fold_mostly_test <- c(TRUE, FALSE, FALSE, FALSE, FALSE)
  split2 <- spatialFolds:::fold_to_rsplit(fold = fold_mostly_test, data = test_data)

  expect_equal(nrow(rsample::analysis(split2)), 1)
  expect_equal(nrow(rsample::assessment(split2)), 4)
})

test_that("fold_to_rsplit preserves data attributes",
  {
  # Create sf data for realistic test
  test_sf <- sf::st_as_sf(
    data.frame(
      id = 1:10,
      value = runif(10),
      x = runif(10, 0, 10),
      y = runif(10, 0, 10)
    ),
    coords = c("x", "y"),
    crs = 4326
  )

  fold <- c(rep(TRUE, 6), rep(FALSE, 4))

  split <- spatialFolds:::fold_to_rsplit(fold = fold, data = test_sf)

  # Check that sf class is preserved
  analysis_data <- rsample::analysis(split)
  expect_s3_class(analysis_data, "sf")

  assessment_data <- rsample::assessment(split)
  expect_s3_class(assessment_data, "sf")
})

# Tests for make_spatial_rset function
test_that("make_spatial_rset creates valid rset object", {
  # Create test data and splits
  test_data <- data.frame(
    x = 1:20,
    y = 21:40
  )

  # Create two folds manually
  fold1 <- c(rep(TRUE, 15), rep(FALSE, 5))
  fold2 <- c(rep(FALSE, 5), rep(TRUE, 15))

  split1 <- spatialFolds:::fold_to_rsplit(fold = fold1, data = test_data)
  split2 <- spatialFolds:::fold_to_rsplit(fold = fold2, data = test_data)

  splits <- list(split1, split2)
  ids <- c("Fold1", "Fold2")

  # Create rset (internal function, accessed via :::)
  rset <- spatialFolds:::make_spatial_rset(
    splits = splits,
    ids = ids,
    subclass = "test_cv"
  )

  # Check class hierarchy
  expect_s3_class(rset, "test_cv")
  expect_s3_class(rset, "spatial_rset")
  expect_s3_class(rset, "rset")
  expect_s3_class(rset, "tbl_df")

  # Check structure
  expect_equal(nrow(rset), 2)
  expect_true("splits" %in% colnames(rset))
  expect_true("id" %in% colnames(rset))

  # Check IDs
  expect_equal(rset$id, c("Fold1", "Fold2"))
})

test_that("make_spatial_rset preserves subclass name correctly", {
  test_data <- data.frame(x = 1:10, y = 11:20)
  fold <- c(rep(TRUE, 8), rep(FALSE, 2))
  split <- spatialFolds:::fold_to_rsplit(fold = fold, data = test_data)

  # Test with different subclass names
  rset_contiguous <- spatialFolds:::make_spatial_rset(
    splits = list(split),
    ids = "Fold1",
    subclass = "spatial_contiguous_cv"
  )
  expect_true("spatial_contiguous_cv" %in% class(rset_contiguous))

  rset_blocks <- spatialFolds:::make_spatial_rset(
    splits = list(split),
    ids = "Fold1",
    subclass = "spatial_blocks_cv"
  )
  expect_true("spatial_blocks_cv" %in% class(rset_blocks))
})

test_that("make_spatial_rset works with multiple splits", {
  test_data <- data.frame(x = 1:50, y = 51:100)

  # Create 5 folds
  splits <- list()
  ids <- character(5)

  for (i in 1:5) {
    fold <- rep(TRUE, 50)
    # Each fold excludes different 10 rows
    fold[((i - 1) * 10 + 1):(i * 10)] <- FALSE
    splits[[i]] <- spatialFolds:::fold_to_rsplit(fold = fold, data = test_data)
    ids[i] <- paste0("Fold", i)
  }

  rset <- spatialFolds:::make_spatial_rset(
    splits = splits,
    ids = ids,
    subclass = "multi_fold_cv"
  )

  expect_equal(nrow(rset), 5)

  # Verify each split has correct dimensions
  for (i in 1:5) {
    analysis_data <- rsample::analysis(rset$splits[[i]])
    expect_equal(nrow(analysis_data), 40)  # 50 - 10 = 40

    assessment_data <- rsample::assessment(rset$splits[[i]])
    expect_equal(nrow(assessment_data), 10)
  }
})
