library(tidyverse)
library(glue)
library(readxl)

library(boxr)
box_auth(
  client_id = Sys.getenv("BOX_CLIENT_ID"),
  client_secret = Sys.getenv("BOX_CLIENT_SECRET")
)

extract_fy_year <- function(file, end = FALSE) {
  library(stringr)
  fy_pattern <- "(?i)(?:FY|CY)[\\s_]*(\\d{1,4}(?:-\\d{1,4})?)"

  # 1) Does the filename contain an FY pattern at all?
  has_fy <- str_detect(file, fy_pattern)

  # 2) If found, extract exactly what matched, else NA
  fy_match <- ifelse(has_fy, str_extract(file, fy_pattern), NA_character_)

  # 3) Clean that match:
  #    - Remove "FY", underscores, and spaces
  #    - Convert e.g. "08" => "2008"
  #    - Convert e.g. "08-09" => "2008-2009"
  fy_str <- ifelse(
    !is.na(fy_match),
    fy_match |>
      str_replace_all("(?i)(?:FY|CY)|\\s+|_", "") |>
      str_replace_all("^(\\d{2})$", "20\\1") |> # e.g. "08" => "2008"
      str_replace_all("^(\\d{1})$", "200\\1") |> # in case single digit
      str_replace_all("^(\\d{2})-(\\d{2})$", "20\\1-20\\2"), # "08-09" => "2008-2009"
    NA_character_
  )

  # If fy_str is NA, we can return NA immediately
  if (is.na(fy_str)) {
    return(NA_integer_)
  }

  # Split out first and second possible years
  parts <- str_split(fy_str, "-", simplify = TRUE)
  first_str <- parts[1]
  second_str <- ifelse(ncol(parts) > 1, parts[2], NA_character_)

  # Convert those strings to integers
  first_int <- as.integer(first_str)
  second_int <- as.integer(second_str)

  # 4) Make a variable start_year that is the lower of the two ints (if both exist) or just first_int
  start_year <- if (!is.na(second_int) && first_int > second_int) {
    second_int
  } else {
    first_int
  }

  # 5) Make a variable end_year that is the higher of the two ints or just first_int (if only one)
  end_year <- if (!is.na(second_int) && first_int > second_int) {
    first_int
  } else if (is.na(second_int) && !is.na(first_int)) {
    first_int
  } else {
    second_int
  }

  # Finally return either 'start' year or 'end' year
  if (end == FALSE) {
    return(start_year)
  } else {
    return(end_year)
  }
}

extract_quarter_range <- function(file, end = FALSE) {
  library(stringr)

  # Updated regex pattern explanation:
  # (?i)            : case-insensitive matching
  # q(\\d)         : matches 'q' (or 'Q') followed by a digit (captures as group 1)
  # (?:             : start of an optional non-capturing group
  #   \\s*         : optional whitespace
  #   (?:[-_])?    : an optional dash or underscore
  #   \\s*         : optional whitespace
  #   (?:q)?       : an optional "q" (for cases like "Q1Q2" or "Q1-Q2")
  #   (\\d)        : a digit (captures as group 2)
  # )?              : the entire group is optional
  quarter_pattern <- "(?i)q(\\d)(?:\\s*(?:[-_])?\\s*(?:q)?(\\d))?"

  # Extract the match using str_match; returns a matrix with captured groups
  q_match <- str_match(file, quarter_pattern)

  # If no quarter pattern found, default to Q1 - Q4
  if (all(is.na(q_match))) {
    quarter_start <- 1
    quarter_end <- 4
  } else {
    # q_match[2] is the first quarter digit and q_match[3] the optional second quarter digit
    quarter_start <- as.integer(q_match[2])
    quarter_end <- as.integer(q_match[3])

    # If the second quarter is missing, default it to the first quarter value
    if (is.na(quarter_end)) {
      quarter_end <- quarter_start
    }
  }

  # Return quarter_start if end==FALSE, otherwise return quarter_end
  if (!end) {
    return(quarter_start)
  } else {
    return(quarter_end)
  }
}

federal_quarter_date <- function(year, quarter, end = FALSE) {
  # Validate quarter input
  if (!quarter %in% 1:4) {
    stop("quarter must be an integer between 1 and 4")
  }

  # Define start and end dates for each federal quarter
  if (quarter == 1) {
    if (end == FALSE) {
      # Q1 starts October 1 of the previous year
      date_str <- str_c(year - 1, "-10-01")
    } else {
      # position == "end"
      # Q1 ends December 31 of the previous year
      date_str <- str_c(year - 1, "-12-31")
    }
  } else if (quarter == 2) {
    if (end == FALSE) {
      date_str <- str_c(year, "-01-01")
    } else {
      date_str <- str_c(year, "-03-31")
    }
  } else if (quarter == 3) {
    if (end == FALSE) {
      date_str <- str_c(year, "-04-01")
    } else {
      date_str <- str_c(year, "-06-30")
    }
  } else if (quarter == 4) {
    if (end == FALSE) {
      date_str <- str_c(year, "-07-01")
    } else {
      date_str <- str_c(year, "-09-30")
    }
  }

  # Convert the constructed string to an R Date object
  as.Date(date_str)
}

fiscal_summary <- function(start_year, start_quarter, end_year, end_quarter) {
  if (is.na(start_year)) {
    return("")
  }

  # For a single fiscal year
  if (start_year == end_year) {
    if (start_quarter == 1 && end_quarter == 4) {
      # Full fiscal year
      return(str_c("FY ", start_year))
    } else if (start_quarter == end_quarter) {
      # Single quarter
      return(str_c("FY ", start_year, " Q", start_quarter))
    } else {
      # Partial fiscal year range
      return(str_c("FY ", start_year, " Q", start_quarter, "-Q", end_quarter))
    }
  } else {
    # Multi-year range
    if (start_quarter == 1 && end_quarter == 4) {
      # Full years on both ends
      return(str_c("FY ", start_year, " to FY ", end_year))
    } else {
      # Partial years
      return(str_c(
        "FY ",
        start_year,
        " Q",
        start_quarter,
        " to FY ",
        end_year,
        " Q",
        end_quarter
      ))
    }
  }
}

box_ids <-
  boxr::box_search_files(
    query = "xlsx|csv|txt|zip|pdf",
    ancestor_folder_ids = 317095269502,
    max = 50000
  ) |>
  as.data.frame() |>
  tibble::as_tibble() |>
  select(name, path, id)

metadata <-
  box_ids |>
  mutate(
    Agency = str_split_i(path, "/", 3) |> str_to_upper(),
    Type = str_split_i(path, "/", 4),
    Release = str_split_i(path, "/", 5),
    path = str_remove(path, "^All Files/deportationdata-web-archive/"),
  )

write_rds(
  metadata,
  file = "metadata.rds"
)
