#defines objects with coordinate column names
coordinates_names <- list(
  x = c(
    "x",
    "easting",
    "x_coord",
    "coord_x",
    "east",
    "longitude",
    "long",
    "lon",
    "lng"
  ),
  y = c(
    "y",
    "northing",
    "y_coord",
    "coord_y",
    "north",
    "latitude",
    "lat"
  )
)

usethis::use_data(coordinates_names)
