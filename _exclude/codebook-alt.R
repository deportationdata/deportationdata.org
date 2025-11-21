library(reactable)
library(tidyverse)

library(googlesheets4)
gs4_deauth()

# Define the URL of the Google Sheets document
url <- "https://docs.google.com/spreadsheets/d/1LD4WSEHNRwnTxIY6I9eau2VOqonOL0_MOhnIwknyzHQ/edit?gid=0#gid=0"
# Read the data from the Google Sheets document
tables <- read_sheet(url, sheet = "tables")
fields <- read_sheet(url, sheet = "fields_edited")
values <- read_sheet(url, sheet = "values", col_types = "c")
missingness_df <- read_rds(here::here("missingness_by_field.rds"))

check_def <- colDef(
  width = 130,
  align = "center",
  style = list(whiteSpace = "nowrap"),
  html = TRUE, # allow htmltools tags
  cell = function(value) {
    if (identical(value, "Y")) {
      htmltools::tags$div(
        style = "display: flex; justify-content: center; align-items: center;",
        htmltools::tags$i(
          class = "fas fa-check",
          style = "font-size: 1.2em; color: green;"
        )
      )
    } else if (identical(value, "R")) {
      htmltools::tags$div(
        style = "display: flex; justify-content: center; align-items: center;",
        htmltools::tags$i(
          class = "fas fa-exclamation-triangle",
          style = "font-size: 1.2em; color: orange;"
        )
      )
    } else if (identical(value, "N")) {
      ""
    } else if (!is.na(value)) {
      value
    } else if (is.na(value)) {
      "—"
    }
  }
)

fields_tbl <-
  fields |>
  filter(!name_in_foia_request %in% c("felon", "msc_conviction_date")) |>
  select(-`Admin Arrests`, -Detainers, -Encounters, -Detentions, -Removals) |>
  select(-in_recent) |>
  mutate(
    name_merge = if_else(is.na(column_names), name_merge_recent, column_names)
  ) |>
  # recode from "Alien File Number" to "Anonymized Identifier"; "Case ID" to "EID Case ID"; "Subject ID" to "EID Subject ID"
  mutate(
    name_merge = str_replace_all(
      name_merge,
      "Alien File Number",
      "Anonymized Identifier"
    ),
    name_merge = str_replace_all(name_merge, "Case ID", "EID Case ID"),
    name_merge = str_replace_all(name_merge, "Subject ID", "EID Subject ID")
  ) |>
  filter(!is.na(name_merge)) |>
  left_join(
    missingness_df |> mutate(in_recent = 1),
    by = c("name_merge" = "field")
  ) |>
  mutate(
    in_recent = if_else(is.na(in_recent), 0, in_recent)
  ) |>
  rename(Name = name_merge, Description = description, Type = type)

fields_tbl_redacted <-
  fields_tbl |>
  select(Name, contains("redacted") | contains("missing")) |>
  pivot_longer(
    cols = c(everything(), -Name),
    names_to = c("type", ".value"),
    names_sep = "_",
    values_drop_na = FALSE
  ) |>
  filter(type == "redacted") |>
  select(-type) |>
  # pivot longer but keep Name
  pivot_longer(
    cols = c(everything(), -Name),
    names_to = "Table",
    values_to = "redaction_value"
  ) |>
  group_by(Name) |>
  summarise(
    all_redacted = !all(is.na(redaction_value)) &&
      all(redaction_value[!is.na(redaction_value)] == 1),
    any_redacted = any(redaction_value == 1, na.rm = TRUE),
    .groups = "drop"
  )

fields_tbl <-
  fields_tbl |>
  left_join(fields_tbl_redacted, by = "Name") |>
  filter(all_redacted == FALSE) |>
  select(-all_redacted, -any_redacted)

has_variable <-
  fields_tbl |>
  select(Name, contains("redacted")) |>
  # rename all removing redacted
  rename_with(
    ~ str_replace_all(.x, "redacted_", ""),
    contains("redacted")
  ) |>
  # set row names to be c("In latest data", "% missing in latest")
  mutate(
    across(
      c(everything(), -Name),
      ~ !is.na(.x)
    ),
    .keep = "unused"
  )

fields_tbl |>
  filter(in_recent == 1) |>
  select(Name, Description, Type) |>
  left_join(has_variable) |>
  arrange(Name) |>
  mutate(
    Name = Name |>
      str_replace_all(" yes no", " (Yes/No)") |>
      str_replace_all(" Yes No", " (Yes/no)")
  ) |>
  # create variable for count of how many tables have this variable
  mutate(
    n_tables = rowSums(across(where(is.logical)))
  ) |>
  filter(n_tables == 1, Detentions == TRUE) |>
  select(1:3) |>
  writexl::write_xlsx("~/downloads/detentions.xlsx")

# reactable(
#   fields_tbl |>
#     filter(in_recent == 1) |>
#     select(Name, Description, Type) |>
#     mutate(
#       Name = Name |>
#         str_replace_all(" yes no", " (Yes/No)") |>
#         str_replace_all(" Yes No", " (Yes/no)")
#     ) |>
#     arrange(Name),
#   pagination = FALSE,
#   striped = TRUE,
#   searchable = TRUE,
#   filterable = FALSE,
#   theme = reactableTheme(
#     # clear the table itself
#     tableStyle = list(backgroundColor = "transparent"),
#     # keep the cells transparent too
#     headerStyle = list(backgroundColor = "transparent")
#   ),
#   columns = list(
#     Name = colDef(minWidth = 100),
#     Description = colDef(minWidth = 200, sortable = FALSE),
#     Type = colDef(minWidth = 65)
#   ),
#   details = function(index) {
#     var_name <- fields_tbl |>
#       filter(in_recent == 1) |>
#       arrange(Name) |>
#       slice(index) |>
#       pull(Name)

#     val_tbl <- values_tbl |>
#       filter(Variable == var_name) |>
#       select(Value, `Value label`) |>
#       arrange(Value)

#     missgn_tbl <-
#       fields_tbl |>
#       filter(Name == var_name) |>
#       select(contains("redacted") | contains("missing")) |>
#       pivot_longer(
#         cols = everything(),
#         names_to = c("type", ".value"),
#         names_sep = "_",
#         values_drop_na = FALSE
#       ) |>
#       select(-type) |>
#       # set row names to be c("In latest data", "% missing in latest")
#       mutate(
#         rownames = if_else(row_number() == 1, "In latest data?", "% missing"),
#         across(where(is.numeric), ~ as.character(round(. * 100))),
#         across(
#           c(everything(), -rownames),
#           ~ case_when(
#             row_number() == 1 & is.na(.) ~ "N",
#             row_number() == 1 & !is.na(.) & . == 0 ~ "Y",
#             row_number() == 1 & !is.na(.) & . == 1 ~ "R",
#             row_number() == 2 & is.na(.) ~ NA_character_,
#             TRUE ~ .
#           )
#         )
#       ) |>
#       relocate(rownames)

#     # collect the pieces we want to show
#     pieces <- list()

#     # Determine if this is an odd or even row (1-indexed)
#     row_color <- if (index %% 2 == 0) "white" else "#F7F7F7"

#     if (nrow(missgn_tbl) > 0) {
#       pieces <- c(
#         pieces,
#         list(
#           htmltools::tags$h4(
#             style = "margin-top: 0rem; margin-bottom: 0.5rem;",
#             "Data availability and missingness"
#           ),
#           reactable(
#             missgn_tbl,
#             # outlined = TRUE,
#             sortable = FALSE,
#             # striped = TRUE,
#             fullWidth = FALSE,
#             # make the table transparent
#             theme = reactableTheme(
#               backgroundColor = row_color,
#               borderColor = "#ddd",
#               headerStyle = list(backgroundColor = row_color),
#               # add horizontal lines only in between rows
#               rowStyle = list(
#                 borderBottom = "1px solid #ddd",
#                 backgroundColor = row_color
#               ),
#               # add vertical spacing at bottom
#               footerStyle = list(paddingBottom = "2rem")
#             ),
#             columns = list(
#               # set columns to be check if "Y"
#               rownames = colDef(
#                 name = "",
#                 style = list(whiteSpace = "nowrap"),
#                 width = 125,
#                 align = "left"
#               ),
#               `Admin Arrests` = check_def,
#               Detainers = check_def,
#               Encounters = check_def,
#               Detentions = check_def,
#               Removals = check_def
#             )
#           )
#         )
#       )
#     }

#     # drop the Value-label column if it’s all NA
#     if (all(is.na(val_tbl$`Value label`))) {
#       val_tbl$`Value label` <- NULL
#     }

#     if (nrow(val_tbl) > 0) {
#       col_defs <- purrr::set_names(
#         lapply(names(val_tbl), \(col) {
#           colDef(name = col, minWidth = 150)
#         }),
#         names(val_tbl)
#       )

#       # pieces <- c(pieces,
#       #   list(
#       #     htmltools::tags$h4(
#       #       style = glue::glue("margin-bottom: 1rem;"),
#       #       "Values and value labels"
#       #     ),
#       #     reactable(
#       #       val_tbl,
#       #       # outlined = TRUE,
#       #       compact  = TRUE,
#       #       # striped = TRUE,
#       #       theme = reactableTheme(
#       #         backgroundColor = row_color,
#       #         borderColor = "#ddd",
#       #         headerStyle = list(backgroundColor = row_color),
#       #         # add horizontal lines only in between rows
#       #         rowStyle = list(
#       #           borderBottom = "1px solid #ddd",
#       #           backgroundColor = row_color
#       #         )
#       #       ),
#       #       defaultPageSize = 25,
#       #       columns  = col_defs
#       #     )
#       #   )
#       # )
#     }

#     # nothing to show for this row
#     if (length(pieces) == 0) {
#       return(NULL)
#     }

#     htmltools::div(
#       style = paste0(
#         "padding: 1rem; margin-bottom: 1.5rem; background-color: ",
#         row_color,
#         ";"
#       ),
#       htmltools::tagList(pieces)
#     )
#   }
# )
# ```

# ### Fields (variables) in previous data releases

# We also provide a table of fields (a.k.a. variables or columns) that were available in previous ICE data releases but are not included in the most recent data. This table includes the name of each field, a description, and the type of data in the field (e.g., string, numeric, date).

# ```{r}
# reactable(
#   fields_tbl |>
#     filter(in_recent == 0) |>
#     select(Name, Description, Type) |>
#     mutate(
#       Name = Name |>
#         str_replace_all(" yes no", " (Yes/No)") |>
#         str_replace_all(" Yes No", " (Yes/no)")
#     ) |>
#     arrange(Name),
#   pagination = FALSE,
#   striped = TRUE,
#   searchable = TRUE,
#   filterable = FALSE,
#   theme = reactableTheme(
#     # clear the table itself
#     tableStyle = list(backgroundColor = "transparent"),
#     # keep the cells transparent too
#     headerStyle = list(backgroundColor = "transparent")
#   ),
#   columns = list(
#     Name = colDef(minWidth = 100),
#     Description = colDef(minWidth = 200, sortable = FALSE),
#     Type = colDef(minWidth = 65)
#   )
# )
# ```
