# ============================================================================
# Interactive Globe Visualization of Spherical Training Folds
# ============================================================================
# This script demonstrates how to visualize training/testing folds
# on an interactive 3D globe using the threejs package.
#
# Install threejs if needed: install.packages("threejs")
# ============================================================================

library(threejs)
library(spatialFolds)

# ============================================================================
# Example 1: Polar data (near North Pole)
# ============================================================================

set.seed(123)

# Create data concentrated near the North Pole
# This is where spherical geometry is essential
polar_xy <- cbind(

  x = runif(500, -180, 180),
  y = runif(500, 70, 90)
)

# Convert to 3D Cartesian for spherical method
polar_xyz <- cast_xy_to_xyz(polar_xy)

# Generate a spherical training fold centered on point 1
training_polar <- method_contiguous_spherical(

  xyz = polar_xyz,
  center = 1,
  angular_step = 0.01,
  target = 250
)

# Visualize on globe
# threejs expects lat/lon, colors can be specified per point
globejs(
  lat = polar_xy[, 2],
  long = polar_xy[, 1],
  value = ifelse(training_polar, 30, 10),  # size of points
  color = ifelse(training_polar, "#3366CC", "#CC3333"),  # blue=training, red=testing
  atmosphere = TRUE,
  bg = "white"
)


# ============================================================================
# Example 2: Dateline-crossing data
# ============================================================================

set.seed(456)

# Create data that spans the dateline (lon ~180/-180)
dateline_xy <- cbind(
  x = c(runif(250, 160, 180), runif(250, -180, -160)),
  y = runif(500, -30, 30)
)

# Convert to 3D Cartesian
dateline_xyz <- cast_xy_to_xyz(dateline_xy)

# Find a point near the dateline to center the fold
center_idx <- which.min(abs(dateline_xy[, 1] - 175))

# Generate spherical fold - should correctly include points on BOTH sides
training_dateline <- method_contiguous_spherical(
  xyz = dateline_xyz,
  center = center_idx,
  angular_step = 0.01,
  target = 300
)

# Visualize - notice how the fold crosses the dateline correctly
globejs(
  lat = dateline_xy[, 2],
  long = dateline_xy[, 1],
  value = ifelse(training_dateline, 30, 10),
  color = ifelse(training_dateline, "#3366CC", "#CC3333"),
  atmosphere = TRUE,
  bg = "white"
)


# ============================================================================
# Example 3: Compare planar vs spherical at the pole
# ============================================================================

set.seed(789)

# Data very close to the North Pole
pole_xy <- cbind(
  x = runif(300, -180, 180),
  y = runif(300, 85, 90)
)

pole_xyz <- cast_xy_to_xyz(pole_xy)

# Find the point closest to the pole
pole_center <- which.max(pole_xy[, 2])

# Spherical fold - should create a proper circular cap
training_spherical <- method_contiguous_spherical(
  xyz = pole_xyz,
  center = pole_center,
  angular_step = 0.005,
  target = 150
)

# Planar fold - will create a rectangle (incorrect at pole)
training_planar <- method_contiguous_planar(
  xy = pole_xy,
  center = pole_center,
  step_x = 1,
  step_y = 0.1,
  target = 150
)

# Compare the two approaches
cat("Spherical method selected:", sum(training_spherical), "points\n")
cat("Planar method selected:", sum(training_planar), "points\n")

# Longitude range of selected points (spherical should span more)
cat("\nSpherical - longitude range of training points:",
    diff(range(pole_xy[training_spherical, 1])), "degrees\n")
cat("Planar - longitude range of training points:",
    diff(range(pole_xy[training_planar, 1])), "degrees\n")

# Visualize spherical result
globejs(
  lat = pole_xy[, 2],
  long = pole_xy[, 1],
  value = ifelse(training_spherical, 30, 10),
  color = ifelse(training_spherical, "#3366CC", "#CC3333"),
  atmosphere = TRUE,
  bg = "white"
)

# Visualize planar result (notice the rectangular pattern)
globejs(
  lat = pole_xy[, 2],
  long = pole_xy[, 1],
  value = ifelse(training_planar, 30, 10),
  color = ifelse(training_planar, "#3366CC", "#CC3333"),
  atmosphere = TRUE,
  bg = "white"
)


# ============================================================================
# Example 4: Using spatial_contiguous_cv() with auto-detection
# ============================================================================

# Create an sf object with polar data
polar_sf <- sf::st_as_sf(

  as.data.frame(polar_xy),
  coords = c("x", "y"),

  crs = 4326
)
polar_sf$id <- seq_len(nrow(polar_sf))

# spatial_contiguous_cv() will auto-detect the need for spherical geometry
cv_folds <- spatial_contiguous_cv(

  data = polar_sf,
  v = 3,

  prop = 0.5
)

# Extract the first fold's training indices
fold1_training <- cv_folds$splits[[1]]$in_id

# Create training mask
training_cv <- seq_len(nrow(polar_sf)) %in% fold1_training

# Visualize
globejs(
  lat = polar_xy[, 2],
  long = polar_xy[, 1],
  value = ifelse(training_cv, 30, 10),
  color = ifelse(training_cv, "#3366CC", "#CC3333"),
  atmosphere = TRUE,
  bg = "white"
)


# ============================================================================
# Example 5: Custom globe styling
# ============================================================================

# More elaborate visualization with custom styling
globejs(
  lat = polar_xy[, 2],
  long = polar_xy[, 1],
  value = ifelse(training_polar, 40, 15),
  color = ifelse(training_polar, "#2E86AB", "#E94F37"),
  atmosphere = TRUE,
  bg = "#1a1a2e",  # dark background
  pointsize = 1
)
