# Tests for method_random()
# Algorithm: Fisher-Yates shuffle with seed, select first N indices

test_that("reproducibility: same seed produces identical results", {
  data(xy_matrix)

  result1 <- method_random(
    xy = xy_matrix,
    seed = 123,
    target = 15000
  )

  result2 <- method_random(
    xy = xy_matrix,
    seed = 123,
    target = 15000
  )

  expect_identical(result1, result2)
})

test_that("different seeds produce different results", {
  data(xy_matrix)

  result1 <- method_random(
    xy = xy_matrix,
    seed = 1,
    target = 15000
  )

  result2 <- method_random(
    xy = xy_matrix,
    seed = 999,
    target = 15000
  )

  expect_false(identical(result1, result2))
})

test_that("exact count: sum equals min(target, n), not just >=", {
  data(xy_matrix)
  n <- nrow(xy_matrix)

  # Normal case: target < n
  target <- 15000
  result <- method_random(
    xy = xy_matrix,
    seed = 1,
    target = target
  )
  expect_equal(sum(result), target)

  # Different target
  target2 <- 5000
  result2 <- method_random(
    xy = xy_matrix,
    seed = 1,
    target = target2
  )
  expect_equal(sum(result2), target2)
})

test_that("distribution is uniform across many seeds", {
  # Create small matrix for tractable computation
  n <- 100
  xy_small <- matrix(runif(n * 2), ncol = 2)
  colnames(xy_small) <- c("x", "y")
  target <- 50

  # Track how often each position is selected
  selection_counts <- rep(0, n)
  n_seeds <- 500

  for (seed in seq_len(n_seeds)) {
    result <- method_random(
      xy = xy_small,
      seed = seed,
      target = target
    )
    selection_counts <- selection_counts + as.integer(result)
  }

  # Expected count for each position: n_seeds * target / n = 500 * 50 / 100 = 250
  expected_count <- n_seeds * target / n

  # Each position should be selected roughly equally often
  # Allow 20% deviation from expected (chi-square would be better but this is simpler)
  min_expected <- expected_count * 0.8
  max_expected <- expected_count * 1.2

  # Most positions should fall within expected range
  within_range <- sum(selection_counts >= min_expected & selection_counts <= max_expected)
  expect_true(
    within_range >= n * 0.9,
    info = paste(
      "Expected uniform distribution.",
      "Positions within 20% of expected:", within_range, "/", n
    )
  )
})

test_that("edge case: target > n caps at n", {
  data(xy_matrix)
  n <- nrow(xy_matrix)

  result <- method_random(
    xy = xy_matrix,
    seed = 1,
    target = n + 1000
  )

  # Should select exactly n points (all of them)
  expect_equal(sum(result), n)
  expect_true(all(result))
})

test_that("edge case: target = 1 selects exactly one point", {
  data(xy_matrix)

  result <- method_random(
    xy = xy_matrix,
    seed = 42,
    target = 1
  )

  expect_equal(sum(result), 1)
})

test_that("edge case: target = 0 selects no points", {
  data(xy_matrix)

  result <- method_random(
    xy = xy_matrix,
    seed = 1,
    target = 0
  )

  expect_equal(sum(result), 0)
  expect_true(all(!result))
})

test_that("output has correct length", {
  data(xy_matrix)
  n <- nrow(xy_matrix)

  result <- method_random(
    xy = xy_matrix,
    seed = 1,
    target = 15000
  )

  expect_equal(length(result), n)
  expect_true(is.logical(result))
})
