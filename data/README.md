# Centralized Dataset Definitions

## Overview

This directory contains a centralized dataset definition system that consolidates all dataset information used across data pages into a single, maintainable file (`datasets.R`).

## Files

### `datasets.R`

The main file containing:
- **`datasets` tibble**: A unified table with all dataset information
- **Helper functions**: Functions to retrieve and format data for display

### Column Structure

The `datasets` tibble includes the following columns:

| Column | Description | Example |
|--------|-------------|---------|
| `agency` | Agency name | "ICE", "CBP", "EOIR", "EOUSA", "OHSS" |
| `category` | Dataset category | "current", "historical", "linked_2012_2023", "reports" |
| `type` | Dataset type | "Arrests", "Detentions", "Apprehensions", etc. |
| `start` | Start date (character or Date) | "Sep. 2023" or `as.Date("2023-09-01")` |
| `end` | End date (character or Date) | "Late Jul. 2025" or `as.Date("2025-07-31")` |
| `identifiers` | Whether dataset has unique IDs | "Late Jul. 2025", "Aug. 2025", NA |
| `records` | Number of records | "292K", "1.8M", etc. |
| `foia` | FOIA request number | "2024-ICFO-39357" |
| `release` | Release date/description | "Early Jun. 2025" |
| `source_label` | Organization name | "CBP", "García Hernández", "NIJC" |
| `source_url` | URL to organization | https://... |
| `box_id` | Box file ID | "1952962832425" (converted to URL) |
| `raw_url` | Direct URL to raw data | https://... (use when no box_id) |
| `raw_size` | File size of raw data | "48MB", "55 MB" |
| `raw_ext` | File extension | "xlsx", "zip", "csv" |
| `processed` | List of processed file info | `list(list(url, size, ext), ...)` |
| `explore_url` | Interactive exploration tool URL | https://... |
| `notes` | Additional notes | NA or descriptive text |

## Helper Functions

### `build_box_url(box_id)`
Converts a Box file ID to a full download URL.

### `get_datasets(agency_name, category_name)`
Retrieves datasets filtered by agency and/or category.

```r
# Get all ICE current datasets
ice_current <- get_datasets("ICE", "current")

# Get all ICE datasets (all categories)
all_ice <- get_datasets("ICE")

# Get all current datasets (all agencies)
all_current <- get_datasets(category_name = "current")
```

### `prepare_for_display(df)`
Prepares ICE dataset data for display in reactable tables (includes Processed and Explore columns).

### `prepare_cbp_for_display(df)`
Prepares CBP dataset data for display in reactable tables (includes Source column, dates as Date objects).

## Usage in Data Pages

### ICE Page (`ice.qmd`)

```r
# Load centralized definitions
source("datasets.R")

# Display current datasets
get_datasets("ICE", "current") %>%
  prepare_for_display() %>%
  reactable::reactable(
    columns = col_defs_ice,
    sortable = FALSE,
    pagination = FALSE
  )

# Display linked 2012-2023 datasets
get_datasets("ICE", "linked_2012_2023") %>%
  prepare_for_display() %>%
  reactable::reactable(
    columns = col_defs_ice[
      !names(col_defs_ice) %in% c("Processed", "Explore")
    ],
    sortable = FALSE,
    pagination = FALSE
  )
```

### CBP Page (`cbp.qmd`)

```r
# Load centralized definitions
source("datasets.R")

# Display current datasets
get_datasets("CBP", "current") %>%
  prepare_cbp_for_display() %>%
  reactable::reactable(columns = col_defs, pagination = FALSE)
```

## Adding New Datasets

To add a new dataset to the centralized file:

1. Open `datasets.R`
2. Add a new row to the `datasets` tribble following the existing pattern
3. Include all relevant columns (use NA for columns that don't apply)
4. For Box files, provide the `box_id`; for direct URLs, provide `raw_url`
5. For processed files, create a list of lists: `list(list(url, size, ext), list(url, size, ext), ...)`

Example:
```r
"ICE", "current", "New Dataset", "Jan. 2025", "Dec. 2025", "Yes", "500K", 
"2025-ICFO-12345", NA_character_, NA_character_, NA_character_, 
"1234567890123", NA_character_, "100MB", "xlsx",
list(
  list("https://github.com/.../processed.xlsx", "80MB", "xlsx"),
  list("https://github.com/.../processed.dta", "150MB", "dta")
),
"https://explore-tool-url.com", NA_character_
```

## Current Status

### Completed
- ✅ ICE current datasets (5 entries)
- ✅ ICE linked_2012_2023 datasets (4 entries)
- ✅ ICE historical datasets (4 sample entries - ~250 more exist in ice.qmd)
- ✅ CBP current datasets (16 entries)
- ✅ CBP historical datasets (3 sample entries - ~60 more exist in cbp.qmd)
- ✅ Reports datasets (7 sample entries - ~80+ more exist in reports.qmd)
- ✅ Updated ice.qmd to use centralized data
- ✅ Updated cbp.qmd to use centralized data

### Pending
- ⏳ Complete ICE historical archive data (~250 entries)
- ⏳ Complete CBP historical archive data (~60 entries)
- ⏳ Complete Reports data (~80+ entries across multiple report types)
- ⏳ Update reports.qmd to use centralized data
- ⏳ Create prepare_reports_for_display() helper function if needed

## Benefits

1. **Single Source of Truth**: All dataset information in one place
2. **Easy Maintenance**: Update file paths, Box IDs, or metadata in one location
3. **Consistency**: Ensures all pages use the same data structure
4. **Filtering**: Easy to filter by agency, category, or other criteria
5. **Extensibility**: Simple to add new datasets or columns as needed
6. **Reusability**: Same data can be used across multiple pages or exports

## Notes

- The historical archives contain hundreds of entries. Sample entries are included with comments indicating where more data should be added.
- Each agency's historical data follows the same structure and just needs population.
- Reports data has a slightly different structure (often single dates rather than date ranges) but fits within the same schema.
- Box IDs are automatically converted to full URLs by the `build_box_url()` helper function.
