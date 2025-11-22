library(tidyverse)

# Function to check if a column is not blank or redacted
is_blank_or_redacted <- function(x) {
  if (is.character(x)) {
    vals <- str_squish(x)
    # Check if all values are NA, all empty, or all redaction patterns
    redact_pattern <- regex(
      "\\(b\\)|\\(B\\)|b\\([0-9]\\)|B\\([0-9]\\)",
      ignore_case = TRUE
    )

    # Handle NA values explicitly in str_detect
    redacted <- str_detect(vals, redact_pattern)
    redacted[is.na(redacted)] <- FALSE # Treat NA as non-redacted for this check

    return(all(is.na(x) | vals == "" | vals == "NA" | redacted))
  } else {
    # For non-character columns, keep them if not all NA
    return(all(is.na(x)))
  }
}

metadata <- read_rds(here::here("metadata.rds"))

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
        df_head <- readxl::read_excel(
          file_path,
          col_names = FALSE,
          skip = 0,
          n_max = 50
        )
        start_row <- janitor::find_header(df_head)
        df <- readxl::read_excel(
          file_path,
          skip = start_row - 1
        )
      } else if (tools::file_ext(row$name) == "csv") {
        df <- readr::read_delim(file_path)
      }

      cols <- df |>
        summarize(across(everything(), is_blank_or_redacted))
    },
    error = function(e) {
      cols <- NA_character_ # or list(NA) if you want to keep it as a list
    }
  )
  metadata_csv_xls$col_names[i] <- list(cols)
}

metadata_csv_xls |>
  select(id, col_names) |>
  unnest(col_names) |>
  # mutate(pivot_id = row_number(), .by = c(name, path, id)) |>
  pivot_longer(
    cols = c(-id),
    names_to = "column_name",
    values_to = "is_blank_or_redacted"
  ) |>
  filter(!is.na(is_blank_or_redacted)) |>
  arrow::write_feather("resources/col_names_by_table.feather")
