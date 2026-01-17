library(collinear)
library(dplyr)
library(usethis)
library(sf)

data(vi)

xy_matrix <- vi |>
  dplyr::mutate(
    id = dplyr::row_number()
  ) |>
  dplyr::transmute(
    x = round(longitude, 3),
    y = round(latitude, 3)
  ) |>
  dplyr::arrange(x, y) |>
  as.matrix()

usethis::use_data(xy_matrix, compress = "xz", overwrite = TRUE)

xy_sf <- xy_matrix |>
  as.data.frame() |>
  sf::st_as_sf(
    coords = c("x", "y"),
    crs = 4326,
    precision = 3
  ) |>
  dplyr::mutate(
    id = dplyr::row_number()
  ) |>
  dplyr::relocate(
    id,
    .before = geometry
  )

usethis::use_data(xy_sf, compress = "xz", overwrite = TRUE)
