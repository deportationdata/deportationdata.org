library(tidyverse)

metadata <- read_rds("metadata.rds")

metadata_csv_xls <-
  metadata |>
  filter(
    !str_detect(path, "documentation|docs"),
    tools::file_ext(name) %in% c("csv", "xlsx", "xls"),
    Agency != "EOIR",
    !Type %in% c("detention_management", "dedicated_nondedicated")
  )

metadata_csv_xls$col_names <- ""
for (i in metadata_csv_xls |>
  mutate(i = row_number()) |>
  #filter(str_detect(name, "ARTS")) |>
  pull(i)) {
  row <- metadata_csv_xls[i, ]
  file_path <-
    glue::glue(
      "~/Library/CloudStorage/Box-Box/DeportationData-Web-Archive/{row$Agency}/{row$Type}/{if_else(row$Agency == 'ICE', str_c(row$Release, '/'), '')}{row$name}"
    )
  cols <- NULL
  tryCatch(
    {
      if (tools::file_ext(row$name) %in% c("xlsx", "xls")) {
        df <- readxl::read_excel(
          file_path,
          col_names = FALSE,
          skip = 0,
          n_max = 50
        )
        start_row <- janitor::find_header(df)
        cols <- readxl::read_excel(
          file_path,
          skip = start_row - 1,
          n_max = 10
        ) |>
          colnames()
      } else if (tools::file_ext(row$name) == "csv") {
        cols <- readr::read_delim(file_path, n_max = 0) |> colnames()
      }
    },
    error = function(e) {
      cols <- NA_character_ # or list(NA) if you want to keep it as a list
    }
  )
  metadata_csv_xls$col_names[i] <- list(cols)
}

metadata_csv_xls |>
  select(name, path, id, col_names) |>
  unnest(col_names) |>
  mutate(pivot_id = row_number(), .by = c(name, path, id)) |>
  pivot_wider(
    id_cols = c(name, path, id),
    names_from = pivot_id,
    values_from = col_names
  ) |>
  right_join(metadata_csv_xls |> select(-col_names)) |>
  writexl::write_xlsx("~/downloads/tmp2.xlsx")
