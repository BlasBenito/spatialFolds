test_that("spatial_fold_plot() works with valid inputs", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  training_fold <- method_contiguous_planar(
    xy = xy_subset,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    target = 50
  )

  # Should not error and return invisible
  expect_invisible(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = training_fold
    )
  )
})

test_that("spatial_fold_plot() accepts custom colors", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  training_fold <- method_random(
    xy = xy_subset,
    seed = 1,
    target = 50
  )

  # Should work with custom colors
  expect_invisible(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = training_fold,
      color_training = "green",
      color_testing = "orange"
    )
  )
})

test_that("spatial_fold_plot() accepts different legend positions", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  training_fold <- method_random(
    xy = xy_subset,
    seed = 1,
    target = 50
  )

  # Test different legend positions
  legend_positions <- c("bottomright", "bottom", "bottomleft", "left",
                        "topleft", "top", "topright", "right", "center")

  for (pos in legend_positions) {
    expect_invisible(
      spatial_fold_plot(
        df = xy_subset,
        training_fold = training_fold,
        legend_position = pos
      )
    )
  }
})

test_that("spatial_fold_plot() validates training_fold type", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  # Non-logical training_fold
  expect_error(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = rep(1, 100)
    ),
    "must be a logical vector"
  )

  expect_error(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = rep("TRUE", 100)
    ),
    "must be a logical vector"
  )
})

test_that("spatial_fold_plot() validates training_fold length", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  # Wrong length
  expect_error(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = c(TRUE, FALSE, TRUE)
    ),
    "must be of the same length"
  )

  expect_error(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = rep(TRUE, 200)
    ),
    "must be of the same length"
  )
})

test_that("spatial_fold_plot() validates xy columns", {
  # Single column xy
  xy_single <- matrix(1:10, ncol = 1)

  expect_error(
    spatial_fold_plot(
      df = xy_single,
      training_fold = rep(TRUE, 10)
    ),
    "must have at least two columns"
  )
})

test_that("spatial_fold_plot() validates numeric coordinates", {
  # Non-numeric coordinates
  xy_char <- matrix(c("a", "b", "c", "d"), ncol = 2)

  expect_error(
    spatial_fold_plot(
      df = xy_char,
      training_fold = c(TRUE, FALSE)
    ),
    "must be a dataframe or matrix with two numeric columns"
  )
})

test_that("spatial_fold_plot() works with data.frame input", {
  data(xy_matrix)

  xy_df <- as.data.frame(xy_matrix[1:100, ])

  training_fold <- method_random(
    xy = xy_matrix[1:100, ],
    seed = 1,
    target = 50
  )

  expect_invisible(
    spatial_fold_plot(
      df = xy_df,
      training_fold = training_fold
    )
  )
})

test_that("spatial_fold_plot() works with all TRUE or all FALSE folds", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  # All training
  expect_invisible(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = rep(TRUE, 100)
    )
  )

  # All testing
  expect_invisible(
    spatial_fold_plot(
      df = xy_subset,
      training_fold = rep(FALSE, 100)
    )
  )
})
