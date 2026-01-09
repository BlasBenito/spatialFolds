# R training_fold ----
training <- training_fold(
  xy = xy_matrix,
  center = 10000,
  step_x = 0.4,
  step_y = 0.1,
  training_fraction = 0.50
)

spatial_fold_plot(
  xy = xy_matrix,
  center = 10000,
  training_fold = training
)

# C++ training_fold_optimized ----
training <- method_contiguous(
  xy = xy_matrix,
  center = 500,
  step_x = 0.4,
  step_y = 0.1,
  target = 500
)

spatial_fold_plot(
  xy = xy_matrix,
  center = 500,
  training_fold = training
)

#benchmark
microbenchmark::microbenchmark(
  training_fold(
    xy = xy_matrix,
    center = 10000,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.50
  ),
  method_contiguous(
    xy = xy_matrix,
    center = 10000,
    step_x = 0.4,
    step_y = 0.1,
    target = 15000
  ),
  times = 100
)
