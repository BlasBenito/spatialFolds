library(spatialFolds)
library(mapview)
data(xy_sf)

y <- spatial_thinning(
  df = xy_sf,
  distance = 5,
  seed = 1
)

z <- spatial_thinning(
  df = xy_sf,
  distance = 5,
  seed = 2
)

mapview(y, col.regions = "blue4") + mapview(z, col.regions = "red4")


y <- spatial_thinning(
  df = xy_sf,
  target = 50,
  seed = 1
)

mapview(xy_sf) + mapview(y, col.regions = "red4")
