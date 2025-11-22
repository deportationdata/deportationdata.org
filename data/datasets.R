# ==============================================================================
# Centralized Dataset Definitions
# ==============================================================================
# This file contains all dataset information used across data pages.
# Each dataset has standardized columns, with NA for fields that don't apply.
#
# Column definitions:
# - agency: ICE, CBP, EOIR, EOUSA, Reports
# - category: current, historical, linked_2012_2023, reports
# - type: Dataset type (Arrests, Detentions, Apprehensions, etc.)
# - start: Start date (character for display, can be dates for CBP)
# - end: End date (character for display, can be dates for CBP)
# - identifiers: Whether dataset has unique IDs (for ICE data)
# - records: Number of records (formatted string like "292K")
# - foia: FOIA request number
# - release: Release date/description
# - source_label: Organization name (for display)
# - source_url: URL to organization
# - box_id: Box file ID (used to construct download URL)
# - raw_url: Direct URL to raw data file
# - raw_size: File size of raw data
# - raw_ext: File extension of raw data
# - processed: List of processed file info (list of lists with url, size, ext)
# - explore_url: URL to interactive exploration tool
# - notes: Additional notes

library(tibble)
library(dplyr)
library(glue)

# Helper function to build Box URLs from box_id
build_box_url <- function(box_id) {
  if (is.na(box_id) || is.null(box_id) || box_id == "") {
    return(NA_character_)
  }
  glue("https://ucla.app.box.com/index.php?rm=box_download_shared_file&shared_name=9d8qnnduhus4bd5mwqt7l95kz34fic2v&file_id=f_{box_id}")
}

# ==============================================================================
# Main Datasets Tibble
# ==============================================================================

datasets <- tribble(
  ~agency, ~category, ~type, ~start, ~end, ~identifiers, ~records, ~foia, ~release, ~source_label, ~source_url, ~box_id, ~raw_url, ~raw_size, ~raw_ext, ~processed, ~explore_url, ~notes,
  
  # ============================================================================
  # ICE - Latest Release (Sep 2023 - Late Jul 2025)
  # ============================================================================
  "ICE", "current", "Arrests", "Sep. 2023", "Late Jul. 2025", "Late Jul. 2025", "292K", "2024-ICFO-39357", NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/8o9t933aq750z7eblcch11z7twexjbn5.xlsx", "48MB", "xlsx",
  list(
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/arrests-latest.xlsx", "38MB", "xlsx"),
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/arrests-latest.dta", "144MB", "dta"),
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/arrests-latest.sav", "119MB", "sav"),
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/arrests-latest.feather", "37MB", "feather")
  ),
  "https://deportationdata-ice-arrests.share.connect.posit.cloud", NA_character_,
  
  "ICE", "current", "Detainers", "Sep. 2023", "Late Jul. 2025", "Late Jul. 2025", "339K", "2024-ICFO-39357", NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/k699orsf5wm8i9ehr1x4foownlj5zuyn.xlsx", "107MB", "xlsx",
  list(), NA_character_, NA_character_,
  
  "ICE", "current", "Detentions", "Sep. 2023", "Late Jul. 2025", "Late Jul. 2025", "1.32M", "2024-ICFO-39357", NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/c6tfgtq90er5df898vaq912okchn9o66.xlsx", "280MB", "xlsx",
  list(), NA_character_, NA_character_,
  
  "ICE", "current", "Encounters", "Sep. 2023", "Late Jul. 2025", "Late Jul. 2025", "1.36M", "2024-ICFO-39357", NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/tp02l4356coo3vzjbbksk51olobzis73.xlsx", "192MB", "xlsx",
  list(), NA_character_, NA_character_,
  
  "ICE", "current", "Removals", "Sep. 2023", "Late Jul. 2025", "Late Jul. 2025", "528K", "2024-ICFO-39357", NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/hrofkgyefmmvki95f487rpk1wigcefd5.xlsx", "129MB", "xlsx",
  list(
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/removals-latest.xlsx", "38MB", "xlsx"),
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/removals-latest.dta", "144MB", "dta"),
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/removals-latest.sav", "119MB", "sav"),
    list("https://github.com/deportationdata/ice/raw/refs/heads/main/data/removals-latest.feather", "37MB", "feather")
  ),
  "https://deportationdata-ice-removals.share.connect.posit.cloud", NA_character_,
  
  # ============================================================================
  # ICE - Linked Data 2012-2023
  # ============================================================================
  "ICE", "linked_2012_2023", "Arrests", "Oct. 2011", "Sep. 2023", "Aug. 2025", "1.8M", NA_character_, NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/3i6xhnd5cig3qacy5phxvw9cmy7a71k1.zip", "99 MB", "zip",
  list(), NA_character_, NA_character_,
  
  "ICE", "linked_2012_2023", "Detentions", "Oct. 2011", "Sep. 2023", "Aug. 2025", "8.5M", NA_character_, NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/gjfcedj3ne4d6l6rt5sv0t6yfao18jzp.zip", "1.41 GB", "zip",
  list(), NA_character_, NA_character_,
  
  "ICE", "linked_2012_2023", "Removals", "Oct. 2011", "Sep. 2023", "Aug. 2025", "2.8M", NA_character_, NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/hanv0cqbvxole910mo63z9uy40cwwi9t.zip", "499 MB", "zip",
  list(), NA_character_, NA_character_,
  
  "ICE", "linked_2012_2023", "Risk classification assessment decisions", "Oct. 2011", "Sep. 2023", "Aug. 2025", "3.5M", NA_character_, NA_character_, NA_character_, NA_character_, NA_character_,
  "https://ucla.box.com/shared/static/x6jxz982onabumgfx0dwnd39b27ggoqz.zip", "596 MB", "zip",
  list(), NA_character_, NA_character_,
  
  # ============================================================================
  # CBP - Current Data
  # ============================================================================
  "CBP", "current", "Apprehensions", as.Date("2024-04-01"), as.Date("2024-06-30"), NA_character_, "340K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1952962832425",
  NA_character_, "55 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", as.Date("2024-12-01"), as.Date("2025-03-31"), NA_character_, "96K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1967490095971",
  NA_character_, "16 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", as.Date("2025-04-01"), as.Date("2025-04-30"), NA_character_, "10K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1905008519753",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", as.Date("2025-05-01"), as.Date("2025-05-31"), NA_character_, "10K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1947452927480",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", as.Date("2025-06-01"), as.Date("2025-06-30"), NA_character_, "8K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1981826641425",
  NA_character_, "5 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2024-10-01"), as.Date("2025-03-19"), NA_character_, "478K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1842173428525",
  NA_character_, "52 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2024-10-01"), as.Date("2025-03-19"), NA_character_, "430K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1842164368478",
  NA_character_, "46 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-03-01"), as.Date("2025-03-31"), NA_character_, "20K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1905033897281",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-04-01"), as.Date("2025-04-30"), NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1904995214241",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-05-01"), as.Date("2025-05-31"), NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1905002524123",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-06-01"), as.Date("2025-06-30"), NA_character_, "17K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1919506153967",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-07-01"), as.Date("2025-07-31"), NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1962793389174",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-08-01"), as.Date("2025-08-31"), NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1981871111017",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-01-01"), as.Date("2025-05-31"), NA_character_, "207K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1988918411932",
  NA_character_, "30 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-06-01"), as.Date("2025-09-06"), NA_character_, "95K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1988922011366",
  NA_character_, "13 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", as.Date("2025-09-01"), as.Date("2025-09-30"), NA_character_, "35K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "2026466901377",
  NA_character_, "5 MB", "xlsx", list(), NA_character_, NA_character_,
  
  # ============================================================================
  # ICE - Historical Archive (sample entries - there are ~250 more in ice.qmd)
  # ============================================================================
  # These use Box IDs in the historical archive table
  "ICE", "historical", "Arrests", as.Date("2023-09-01"), as.Date("2025-06-20"), "249280", "Late Jun. 2025", "2024-ICFO-39357", "Early Jun. 2025", NA_character_, NA_character_, "1903641913782",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "historical", "Arrests", as.Date("2015-10-01"), as.Date("2016-09-30"), "107300", NA_character_, "2022-ICFO-22955", NA_character_, "García Hernández", "https://www.ccgarciahernandez.com", "1851836294057",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "historical", "Detentions", as.Date("2015-10-01"), as.Date("2016-09-30"), "764332", NA_character_, "2019-ICFO-21307", NA_character_, "García Hernández", "https://www.ccgarciahernandez.com", "1851662838490",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "historical", "Removals", as.Date("2002-10-01"), as.Date("2003-09-30"), "159611", NA_character_, "14-03290", NA_character_, "NYT", "https://nytimes.com", "1875129596640",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,
  
  # NOTE: There are approximately 250 more historical entries in ice.qmd
  # covering years from 2002-2025 for various data types (Arrests, Detentions, 
  # Detainers, Encounters, Removals, Flights, Flight passengers)
  # These should be added following the same pattern
  
  # ============================================================================
  # CBP - Historical Archive (sample entries - there are ~60 more in cbp.qmd)
  # ============================================================================
  "CBP", "historical", "Apprehensions", as.Date("2007-10-01"), as.Date("2008-09-30"), NA_character_, "724K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836529466108",
  NA_character_, "45 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "historical", "Deemed inadmissible", as.Date("2014-01-01"), as.Date("2014-12-31"), NA_character_, "557K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536350802",
  NA_character_, "61 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "historical", "Encounters", as.Date("2024-07-01"), as.Date("2024-09-30"), NA_character_, "176K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522527618",
  NA_character_, "27 MB", "xlsx", list(), NA_character_, NA_character_,
  
  # NOTE: There are approximately 60 more historical entries in cbp.qmd
  # covering Apprehensions, Deemed inadmissible, Title 42 expulsions, Encounters,
  # and Apprehensions with place of origin from 1999-2024
  
  # ============================================================================
  # Reports - ICE Detention Management (sample entries from reports.qmd)
  # ============================================================================
  "ICE", "reports", "Detention management YTD", as.Date("2025-10-01"), as.Date("2025-11-17"), NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/detention-management", "2053638251632",
  NA_character_, "215 KB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Detention management annual", as.Date("2023-10-01"), as.Date("2024-09-30"), NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/detention-management", "1836537358917",
  NA_character_, "242 kB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Dedicated and non-dedicated facilities", as.Date("2024-11-13"), as.Date("2024-11-13"), NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/facility-inspections", "2049601281540",
  NA_character_, "NA kB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Over-72-hour facilities", as.Date("2020-01-13"), as.Date("2020-01-13"), NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/detention-management", "2049599555688",
  NA_character_, "NA kB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Annual report", "2024", "2024", NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/information-library/annual-report", "1836539286110",
  NA_character_, "3 MB", "pdf", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Detention facility list", as.Date("2017-11-06"), as.Date("2017-11-06"), NA_character_, NA_character_, NA_character_, NA_character_, "NIJC", "https://immigrantjustice.org/ice-detention-facilities-november-2017", "1836538055645",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  # NOTE: There are many more report entries in reports.qmd (~70+ entries for
  # detention management YTD/annual, plus dedicated/non-dedicated facilities,
  # over-72-hour facilities, annual reports)
  
  # ============================================================================
  # Reports - OHSS Enforcement Statistics  
  # ============================================================================
  "OHSS", "reports", "Enforcement statistics", "Jan. 2025", "Jan. 2025", NA_character_, NA_character_, NA_character_, NA_character_, "OHSS", "https://ohss.dhs.gov/topics/immigration/immigration-enforcement/monthly-tables", "1836538278882",
  NA_character_, "712 kB", "xlsx", list(), NA_character_, NA_character_
  
  # NOTE: There are ~12 more monthly enforcement statistics reports in reports.qmd
)

# Helper function to get datasets for a specific agency and category
get_datasets <- function(agency_name = NULL, category_name = NULL) {
  result <- datasets
  
  if (!is.null(agency_name)) {
    result <- result %>% filter(agency == agency_name)
  }
  
  if (!is.null(category_name)) {
    result <- result %>% filter(category == category_name)
  }
  
  return(result)
}

# Helper function to format raw download column for reactable
format_raw_column <- function(row) {
  # If box_id exists, use it to build URL
  if (!is.na(row$box_id) && row$box_id != "") {
    url <- build_box_url(row$box_id)
    return(list(url, row$raw_size, row$raw_ext))
  }
  # Otherwise use raw_url if it exists
  if (!is.na(row$raw_url) && row$raw_url != "") {
    return(list(row$raw_url, row$raw_size, row$raw_ext))
  }
  # Return empty list if no download available
  return(list())
}

# Helper function to prepare datasets for display in reactable tables
prepare_for_display <- function(df) {
  df %>%
    rowwise() %>%
    mutate(
      # Build Raw column as list for reactable
      Raw = list(format_raw_column(cur_data())),
      # Use processed column as-is (it's already a list)
      Processed = list(processed),
      # Build Explore column
      Explore = list(explore_url)
    ) %>%
    ungroup() %>%
    # Rename columns for display
    select(
      Type = type,
      Start = start,
      End = end,
      Identifiers = identifiers,
      Records = records,
      Raw,
      Processed,
      Explore
    )
}

# Helper function to prepare CBP datasets for display
prepare_cbp_for_display <- function(df) {
  df %>%
    rowwise() %>%
    mutate(
      # Build Raw column as list for reactable
      Raw = list(format_raw_column(cur_data())),
      # Build Source column with link
      Source = if (!is.na(source_label) && !is.na(source_url)) {
        paste0("<a href='", source_url, "'>", source_label, "</a>")
      } else {
        NA_character_
      }
    ) %>%
    ungroup() %>%
    # Rename and select columns for display
    select(
      Type = type,
      Start = start,
      End = end,
      Records = records,
      Source,
      Raw
    )
}
