library(microbenchmark)
library(spatialRF)
library(GeoThinneR)

data("xy_matrix")
xy_df <- as.data.frame(xy_matrix)

y <- microbenchmark(
  thinning_R_naive = spatialRF::thinning(
    xy = xy_df,
    minimum.distance = 10
  ),
  thinning_cpp_naive = thinning_to_distance(
    xy = xy_matrix,
    distance = 10
  ),
  thinning_cpp_optimized = thinning_to_distance(
    xy = xy_matrix,
    distance = 10
  ),
  times = 10L
)

# Unit: milliseconds
#                    expr        min         lq       mean     median         uq        max neval cld
#        thinning_R_naive 49742.4315 49896.3456 49985.2612 50021.8390 50091.9828 50137.9260    10 a
#      thinning_cpp_naive 11542.7235 11554.7385 11560.6383 11561.9877 11567.0566 11576.3906    10  b
#  thinning_cpp_optimized   103.4563   104.3296   104.5626   104.7013   105.1487   105.4228    10   c

#checking output
plot(xy_matrix[, "x"], xy_matrix[, "y"])

y1 <- thinning_to_distance(
  xy = xy_matrix,
  distance = 5
)

par(mfrow = c(2, 1), mar = c(2.2, 3, 2, 1))
plot(
  xy_matrix[, "x"],
  xy_matrix[, "y"],
  xlab = "",
  ylab = "",
  main = "Thinning example (distance = 5º)"
)
plot(xy_matrix[y1, "x"], xy_matrix[y1, "y"], xlab = "Latitude", ylab = "")


y2 <- spatialRF::thinning(
  xy = xy_df,
  minimum.distance = 10
)

plot(y2[, "x"], y2[, "y"])


y <- method_contiguous(
  xy = xy_matrix,
  center = y1[20],
  step_x = 2,
  step_y = 0.5,
  target = 15000
)

spatial_fold_plot(
  xy = xy_matrix,
  training_fold = y
)


library(microbenchmark)
library(spatialRF)

data("xy_matrix")
xy_df <- as.data.frame(xy_matrix)

y <- microbenchmark(
  thinning_R_naive = spatialRF::thinning_til_n(
    xy = xy_df,
    n = 1000
  ),
  thinning_cpp_naive = thinning_to_target(
    xy = xy_matrix,
    target = 1000
  ),
  thinning_cpp_optimized = thinning_to_target(
    xy = xy_matrix,
    target = 1000
  ),
  times = 10L
)
