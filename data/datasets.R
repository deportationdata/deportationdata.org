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
  "CBP", "current", "Apprehensions", "2024-04-01", "2024-06-30", NA_character_, "340K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1952962832425",
  NA_character_, "55 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", "2024-12-01", "2025-03-31", NA_character_, "96K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1967490095971",
  NA_character_, "16 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", "2025-04-01", "2025-04-30", NA_character_, "10K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1905008519753",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", "2025-05-01", "2025-05-31", NA_character_, "10K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1947452927480",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Apprehensions", "2025-06-01", "2025-06-30", NA_character_, "8K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1981826641425",
  NA_character_, "5 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2024-10-01", "2025-03-19", NA_character_, "478K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1842173428525",
  NA_character_, "52 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2024-10-01", "2025-03-19", NA_character_, "430K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1842164368478",
  NA_character_, "46 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-03-01", "2025-03-31", NA_character_, "20K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1905033897281",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-04-01", "2025-04-30", NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1904995214241",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-05-01", "2025-05-31", NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1905002524123",
  NA_character_, "2 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-06-01", "2025-06-30", NA_character_, "17K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1919506153967",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-07-01", "2025-07-31", NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1962793389174",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-08-01", "2025-08-31", NA_character_, "18K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1981871111017",
  NA_character_, "1 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-01-01", "2025-05-31", NA_character_, "207K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1988918411932",
  NA_character_, "30 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-06-01", "2025-09-06", NA_character_, "95K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1988922011366",
  NA_character_, "13 MB", "xlsx", list(), NA_character_, NA_character_,
  
  "CBP", "current", "Deemed inadmissible", "2025-09-01", "2025-09-30", NA_character_, "35K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "2026466901377",
  NA_character_, "5 MB", "xlsx", list(), NA_character_, NA_character_,
  
  # ============================================================================
  "ICE", "historical", "Arrests", "2023-09-01", "2025-06-20", "265000", "NA_character_", "2024-ICFO-39357", "Late Jun. 2025", NA_character_, NA_character_, "1922082018423",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2023-09-01", "2025-06-20", "316000", "NA_character_", "2024-ICFO-39357", "Late Jun. 2025", NA_character_, NA_character_, "1922081034353",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2023-09-01", "2025-06-20", "1230000", "NA_character_", "2024-ICFO-39357", "Late Jun. 2025", NA_character_, NA_character_, "1922078517539",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Encounters", "2023-09-01", "2025-06-20", "1280000", "NA_character_", "2024-ICFO-39357", "Late Jun. 2025", NA_character_, NA_character_, "1922075106849",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2023-09-01", "2025-03-20", "145802", "NA_character_", "2024-ICFO-39357", "Feb. 2025", NA_character_, NA_character_, "1836554372496",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2023-09-01", "2025-06-20", "249280", "NA_character_", "2024-ICFO-39357", "Early Jun. 2025", NA_character_, NA_character_, "1903641913782",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2015-10-01", "2016-09-30", "107300", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851836294057",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2016-10-01", "2017-09-30", "138876", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851833536271",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2017-10-01", "2018-09-30", "153214", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851837546731",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2018-10-01", "2019-09-30", "138775", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851831800585",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2019-10-01", "2020-09-30", "100429", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851835191968",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2020-10-01", "2021-09-30", "72849", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851833034596",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2021-10-01", "2022-09-30", "142954", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851830686826",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2022-10-01", "2023-09-30", "170864", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851836416108",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2023-10-01", "2024-09-30", "95188", "NA_character_", "2022-ICFO-22955", NA_character_, NA_character_, NA_character_, "1851836311169",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2011-10-01", "2012-09-30", "681578", "NA_character_", "2022-ICFO-09023", NA_character_, NA_character_, NA_character_, "1836557464054",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Arrests", "2014-10-01", "2015-09-30", "1059656", "NA_character_", "2022-ICFO-09023", NA_character_, NA_character_, NA_character_, "1836540105544",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2010-10-01", "2011-09-30", "2160", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836540049661",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2011-10-01", "2012-09-30", "2399", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836552599950",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2012-10-01", "2013-09-30", "2333", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836549849021",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2013-10-01", "2014-09-30", "5756", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836540958981",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2014-10-01", "2015-09-30", "1663", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836538695921",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2015-10-01", "2016-09-30", "1884", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836536493019",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2016-10-01", "2017-09-30", "1658", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836549806043",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2017-10-01", "2018-09-30", "1703", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836550883008",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flights", "2018-10-01", "2019-09-30", "1122", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836537162853",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2010-10-01", "2011-09-30", "233061", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836536399014",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2011-10-01", "2012-09-30", "282178", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836538136812",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2012-10-01", "2013-09-30", "263621", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836555001702",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2013-10-01", "2014-09-30", "249563", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836545751933",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2014-10-01", "2015-09-30", "157067", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836539073027",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2015-10-01", "2016-09-30", "168239", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836549772221",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2016-10-01", "2017-09-30", "180384", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836541672269",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2017-10-01", "2018-09-30", "191648", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836553076817",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2018-10-01", "2019-09-30", "37259", "NA_character_", "2019-ICFO-32423", NA_character_, NA_character_, NA_character_, "1836536207751",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2018-10-01", "2020-05-08", "3182", "NA_character_", "2021-ICAP-00188", NA_character_, NA_character_, NA_character_, "1836545668509",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Flight passengers", "2018-10-01", "2020-05-08", "341290", "NA_character_", "2021-ICAP-00188", NA_character_, NA_character_, NA_character_, "1836550007406",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2023-09-01", "2025-03-20", "199335", "NA_character_", "2024-ICFO-39357", "Feb. 2025", NA_character_, NA_character_, "1836552782163",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2023-09-01", "2025-06-20", "305738", "NA_character_", "2024-ICFO-39357", "Early Jun. 2025", NA_character_, NA_character_, "1903648700489",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2009-10-01", "2010-09-30", "290253", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836555210688",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2010-10-01", "2011-09-30", "317327", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836552467952",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2011-10-01", "2012-09-30", "286507", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836540940171",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2012-10-01", "2013-09-30", "216717", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836550482581",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2013-10-01", "2014-09-30", "164188", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836551310786",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2014-10-01", "2015-09-30", "97021", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836547271446",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2015-10-01", "2016-09-30", "85561", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836555104717",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2016-10-01", "2017-09-30", "94013", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836554262318",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2008-10-01", "2009-09-30", "248255", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836543616508",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2007-10-01", "2008-09-30", "212407", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836553974742",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2008-10-01", "2009-09-30", "248272", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836539862966",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2009-10-01", "2010-09-30", "290304", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836543397795",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2010-10-01", "2011-09-30", "603877", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836543308523",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2012-10-01", "2013-09-30", "380916", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836551433566",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detainers", "2014-10-01", "2015-09-30", "79053", "NA_character_", "npr", NA_character_, NA_character_, NA_character_, "1836556496547",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2023-09-01", "2025-03-20", "767747", "NA_character_", "2024-ICFO-39357", "Feb. 2025", NA_character_, NA_character_, "1836559130180",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2023-09-01", "2025-06-20", "1173910", "NA_character_", "2024-ICFO-39357", "Early Jun. 2025", NA_character_, NA_character_, "1903652224645",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2015-10-01", "2016-09-30", "764332", "NA_character_", "2019-ICFO-21307", NA_character_, NA_character_, NA_character_, "1851662838490",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2014-10-01", "2015-09-30", "665212", "NA_character_", "2019-ICFO-21307", NA_character_, NA_character_, NA_character_, "1851667352417",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2016-10-01", "2017-09-30", "692356", "NA_character_", "2019-ICFO-21307", NA_character_, NA_character_, NA_character_, "1851661107897",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2010-10-01", "2011-09-30", "60200", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836558695933",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2011-10-01", "2012-09-30", "988494", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836538890174",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2012-10-01", "2013-09-30", "877453", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836539896765",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2013-10-01", "2014-09-30", "848952", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836558270445",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2014-10-01", "2015-09-30", "654963", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836545212556",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2015-10-01", "2016-09-30", "748077", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836551270304",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2016-10-01", "2017-09-30", "756918", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836545300833",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2017-10-01", "2018-09-30", "903960", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836550118061",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2018-10-01", "2019-09-30", "940511", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836545192598",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2019-10-01", "2020-09-30", "415226", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836540429374",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2020-10-01", "2021-09-30", "363380", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836545015666",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2021-10-01", "2022-09-30", "480921", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836551672923",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2022-10-01", "2023-09-30", "513664", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836556182456",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Detentions", "2023-10-01", "2024-09-30", "114833", "NA_character_", "2022-ICFO-09022", NA_character_, NA_character_, NA_character_, "1836538575856",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Encounters", "2023-09-01", "2025-03-20", "868569", "NA_character_", "2024-ICFO-39357", "Feb. 2025", NA_character_, NA_character_, "1836544630925",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Encounters", "2023-09-01", "2025-06-20", "1241817", "NA_character_", "2024-ICFO-39357", "Early Jun. 2025", NA_character_, NA_character_, "1903642269570",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Encounters", "2011-10-01", "2012-09-30", "2054228", "NA_character_", "2022-ICFO-09023", NA_character_, NA_character_, NA_character_, "1836545587160",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Encounters", "2014-10-01", "2015-09-30", "3470882", "NA_character_", "2022-ICFO-09023", NA_character_, NA_character_, NA_character_, "1836539886526",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2023-09-01", "2025-06-20", "106469", "NA_character_", "2024-ICFO-39357", "Early Jun. 2025", NA_character_, NA_character_, "1903640338806",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2002-10-01", "2003-09-30", "159611", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875129596640",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2011-10-01", "2012-09-30", "409504", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875139734735",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2012-10-01", "2013-09-30", "368807", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875139943394",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2003-10-01", "2004-09-30", "177707", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875132208001",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2004-10-01", "2005-09-30", "183543", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875135429164",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2005-10-01", "2006-09-30", "212205", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875129589363",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2006-10-01", "2007-09-30", "300420", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875129774679",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2007-10-01", "2008-09-30", "383941", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875130303126",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2008-10-01", "2009-09-30", "384567", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875137637027",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2009-10-01", "2010-09-30", "391694", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875138789538",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2010-10-01", "2011-09-30", "396245", "NA_character_", "14-03290", NA_character_, NA_character_, NA_character_, "1875127271383",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2011-10-01", "2014-09-30", "1094451", "NA_character_", "2022-ICFO-09023", NA_character_, NA_character_, NA_character_, "1836557461924",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  "ICE", "historical", "Removals", "2014-10-01", "2023-01-28", "1571114", "NA_character_", "2022-ICFO-09023", NA_character_, NA_character_, NA_character_, "1836555735995",
  NA_character_, NA_character_, "xlsx", list(), NA_character_, NA_character_,

  # ============================================================================
  # CBP - Historical Archive (ALL ENTRIES from original cbp.qmd)
  # ============================================================================
  "CBP", "historical", "Apprehensions", "2007-10-01", "2008-09-30", NA_character_, "724K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836529466108",
  NA_character_, "45 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2008-10-01", "2009-09-30", NA_character_, "556K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836524552711",
  NA_character_, "35 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2009-10-01", "2010-09-30", NA_character_, "463K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836524452168",
  NA_character_, "35 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2010-10-01", "2011-09-30", NA_character_, "340K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836537472516",
  NA_character_, "26 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2011-10-01", "2012-09-30", NA_character_, "365K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522219652",
  NA_character_, "31 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2012-10-01", "2013-09-30", NA_character_, "421K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522010833",
  NA_character_, "40 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2013-10-01", "2014-03-31", NA_character_, "215K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536497781",
  NA_character_, "24 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2014-10-01", "2015-09-30", NA_character_, "337K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836523485219",
  NA_character_, "34 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2015-10-01", "2016-03-31", NA_character_, "189K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836527949432",
  NA_character_, "20 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2016-04-01", "2016-09-30", NA_character_, "227K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536771304",
  NA_character_, "30 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2016-10-01", "2017-09-30", NA_character_, "311K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522642202",
  NA_character_, "34 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2017-10-01", "2018-09-30", NA_character_, "404K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536816904",
  NA_character_, "42 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2018-10-01", "2019-03-31", NA_character_, "365K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836534563529",
  NA_character_, "38 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2019-04-01", "2019-06-30", NA_character_, "329K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836539665388",
  NA_character_, "34 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2019-07-01", "2019-09-30", NA_character_, "165K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836538377500",
  NA_character_, "17 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2019-10-01", "2020-09-30", NA_character_, "208K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836518613189",
  NA_character_, "23 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2020-10-01", "2021-03-31", NA_character_, "126K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836532799369",
  NA_character_, "14 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2021-04-01", "2021-06-30", NA_character_, "200K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836531099951",
  NA_character_, "21 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2021-07-01", "2021-09-30", NA_character_, "296K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836535939039",
  NA_character_, "30 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions", "2021-10-01", "2022-09-30", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836527984953",
  NA_character_, "110 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2014-01-01", "2014-12-31", NA_character_, "557K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536350802",
  NA_character_, "61 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2015-01-01", "2015-12-31", NA_character_, "671K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836517811895",
  NA_character_, "74 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2016-01-01", "2016-12-31", NA_character_, "829K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836530605254",
  NA_character_, "91 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2017-01-01", "2017-12-31", NA_character_, "546K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836529580929",
  NA_character_, "64 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2018-01-01", "2018-12-31", NA_character_, "673K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836538742245",
  NA_character_, "77 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2019-01-01", "2019-12-31", NA_character_, "49K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836519445234",
  NA_character_, "26 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2020-01-01", "2020-12-31", NA_character_, "391K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836519054034",
  NA_character_, "44 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2020-04-01", "2022-03-31", NA_character_, "503K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836517807065",
  NA_character_, "38 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2021-01-01", "2021-12-31", NA_character_, "602K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836537280774",
  NA_character_, "68 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2022-01-01", "2022-12-31", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836527086921",
  NA_character_, "119 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2022-01-01", "2022-12-31", NA_character_, "281K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836534928426",
  NA_character_, "31 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2022-04-01", "2022-04-30", NA_character_, "53K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522332574",
  NA_character_, "4 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2022-07-01", "2023-02-28", NA_character_, "525K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836525107263",
  NA_character_, "38 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2022-07-01", "2023-02-28", NA_character_, "525K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836529242001",
  NA_character_, "38 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-01-01", "2023-12-31", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836524171859",
  NA_character_, "119 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-01-01", "2023-12-31", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836526905068",
  NA_character_, "115 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-01-01", "2023-12-31", NA_character_, "775K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522164658",
  NA_character_, "85 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-05-01", "2023-06-20", NA_character_, "175K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836524781374",
  NA_character_, "12 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-07-01", "2023-07-31", NA_character_, "110K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836521186280",
  NA_character_, "8 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-07-01", "2023-12-31", NA_character_, "708K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836525779953",
  NA_character_, "52 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2023-11-01", "2024-08-01", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836533367753",
  NA_character_, "76 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2024-01-01", "2024-12-31", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836530361246",
  NA_character_, "118 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2024-01-01", "2024-12-31", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836519236948",
  NA_character_, "115 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2024-01-01", "2024-12-31", NA_character_, "477K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536102266",
  NA_character_, "52 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2024-01-01", "2024-06-30", NA_character_, "692K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522055139",
  NA_character_, "51 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Deemed inadmissible", "2024-10-01", "2024-11-30", NA_character_, "163K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836533627763",
  NA_character_, "12 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Title 42 expulsions", "2021-10-01", "2022-09-30", NA_character_, "738K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836530089384",
  NA_character_, "74 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Title 42 expulsions", "2019-10-01", "2020-09-30", NA_character_, "197K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836519515324",
  NA_character_, "18 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Title 42 expulsions", "2020-10-01", "2021-09-30", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836538878230",
  NA_character_, "98 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2024-07-01", "2024-09-30", NA_character_, "176K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522527618",
  NA_character_, "27 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2022-10-01", "2022-12-31", NA_character_, "640K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836519013469",
  NA_character_, "95 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2023-01-01", "2023-03-31", NA_character_, "428K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836523031829",
  NA_character_, "64 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2023-04-01", "2023-06-30", NA_character_, "458K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836539840495",
  NA_character_, "68 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2023-07-01", "2023-09-30", NA_character_, "537K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836528623980",
  NA_character_, "80 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2023-10-01", "2023-12-31", NA_character_, "634K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836529574328",
  NA_character_, "95 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2024-01-01", "2024-03-31", NA_character_, "407K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836538501297",
  NA_character_, "61 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2024-04-01", "2024-06-30", NA_character_, "340K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836524426045",
  NA_character_, "51 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2012-10-01", "2013-09-30", NA_character_, "420K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1973649671540",
  NA_character_, "63 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Encounters", "2017-10-01", "2018-09-30", NA_character_, "404K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1973646575195",
  NA_character_, "64 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "1999-10-01", "2000-09-30", NA_character_, "2M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836526779834",
  NA_character_, "56 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2000-10-01", "2001-09-30", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836521865479",
  NA_character_, "44 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2001-10-01", "2002-09-30", NA_character_, "954K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536752416",
  NA_character_, "34 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2002-10-01", "2003-09-30", NA_character_, "932K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836535002120",
  NA_character_, "34 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2003-10-01", "2004-09-30", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836523854174",
  NA_character_, "43 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2004-10-01", "2005-09-30", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836538413035",
  NA_character_, "43 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2005-10-01", "2006-09-30", NA_character_, "1M", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836525352489",
  NA_character_, "39 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2006-10-01", "2007-09-30", NA_character_, "877K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836520753674",
  NA_character_, "35 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2007-10-01", "2008-09-30", NA_character_, "724K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836537397984",
  NA_character_, "28 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2008-10-01", "2009-09-30", NA_character_, "556K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836528500592",
  NA_character_, "22 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2009-10-01", "2010-09-30", NA_character_, "463K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836537505751",
  NA_character_, "18 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2010-10-01", "2011-09-30", NA_character_, "340K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836536574704",
  NA_character_, "14 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2011-10-01", "2012-09-30", NA_character_, "365K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836523110035",
  NA_character_, "15 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2012-10-01", "2013-09-30", NA_character_, "421K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836527799721",
  NA_character_, "17 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2013-10-01", "2014-09-30", NA_character_, "487K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836529955831",
  NA_character_, "20 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2014-10-01", "2015-09-30", NA_character_, "337K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836531582054",
  NA_character_, "14 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2015-10-01", "2016-09-30", NA_character_, "416K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836537397977",
  NA_character_, "20 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2016-10-01", "2017-09-30", NA_character_, "311K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836525028767",
  NA_character_, "15 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2017-10-01", "2018-09-30", NA_character_, "404K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836539329278",
  NA_character_, "20 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2018-10-01", "2019-09-30", NA_character_, "860K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836526972753",
  NA_character_, "42 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2019-10-01", "2020-09-30", NA_character_, "208K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836527670543",
  NA_character_, "10 MB", "xlsx", list(), NA_character_, NA_character_,

  "CBP", "historical", "Apprehensions with place of origin", "2020-10-01", "2021-09-30", NA_character_, "621K", NA_character_, NA_character_, "CBP", "https://www.cbp.gov/newsroom/accountability-and-transparency/foia-reading-room", "1836522751005",
  NA_character_, "30 MB", "xlsx", list(), NA_character_, NA_character_,



  # Reports - ICE Detention Management (sample entries from reports.qmd)
  # ============================================================================
  "ICE", "reports", "Detention management YTD", "2025-10-01", "2025-11-17", NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/detention-management", "2053638251632",
  NA_character_, "215 KB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Detention management annual", "2023-10-01", "2024-09-30", NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/detention-management", "1836537358917",
  NA_character_, "242 kB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Dedicated and non-dedicated facilities", "2024-11-13", "2024-11-13", NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/facility-inspections", "2049601281540",
  NA_character_, "NA kB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Over-72-hour facilities", "2020-01-13", "2020-01-13", NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/detain/detention-management", "2049599555688",
  NA_character_, "NA kB", "xlsx", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Annual report", "2024", "2024", NA_character_, NA_character_, NA_character_, NA_character_, "ICE", "https://www.ice.gov/information-library/annual-report", "1836539286110",
  NA_character_, "3 MB", "pdf", list(), NA_character_, NA_character_,
  
  "ICE", "reports", "Detention facility list", "2017-11-06", "2017-11-06", NA_character_, NA_character_, NA_character_, NA_character_, "NIJC", "https://immigrantjustice.org/ice-detention-facilities-november-2017", "1836538055645",
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

# Helper function to prepare datasets for display in reactable tables
prepare_for_display <- function(df) {
  df %>%
    rowwise() %>%
    mutate(
      # Build Raw column as list for reactable
      Raw = list(if (!is.na(box_id) && box_id != "") {
        list(build_box_url(box_id), raw_size, raw_ext)
      } else if (!is.na(raw_url) && raw_url != "") {
        list(raw_url, raw_size, raw_ext)
      } else {
        list()
      }),
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
      Raw = list(if (!is.na(box_id) && box_id != "") {
        list(build_box_url(box_id), raw_size, raw_ext)
      } else if (!is.na(raw_url) && raw_url != "") {
        list(raw_url, raw_size, raw_ext)
      } else {
        list()
      }),
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
