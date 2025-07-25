# ICE Detention Management Data Scraper
# Scrapes https://www.ice.gov/detain/detention-management for updates

library(rvest)
library(httr)
library(lubridate)
library(stringr)
library(dplyr)
library(boxr)
library(here)

#' Upload file to Box in deportationdata/ICE/detention_management folder
#' @param local_path Path to local file to upload
#' @return Box file info on success, FALSE on failure
upload_to_box <- function(local_path) {
  tryCatch({
    boxr::box_auth()
    # Assume detention_management folder ID is known - replace with actual ID
    detention_folder_id <- "317093910578"  # Update this with your actual folder ID
    upload_result <- boxr::box_ul(file = local_path, dir_id = detention_folder_id)
    message("Successfully uploaded file to Box: ", basename(local_path))
    return(upload_result)
  }, error = function(e) {
    warning("Failed to upload to Box: ", e$message)
    return(FALSE)
  })
}

#' Verify file exists in Box
#' @param filename Filename to verify in Box
#' @return Box file info on success, FALSE on failure
verify_box_upload <- function(filename) {
  tryCatch({
    file_search <- boxr::box_search(filename, type = "file")
    if (length(file_search) > 0) {
      message("Box file verified: ", filename, " (ID: ", file_search[[1]]$id, ")")
      return(file_search[[1]])
    }
    return(FALSE)
  }, error = function(e) {
    warning("Error verifying Box file: ", e$message)
    return(FALSE)
  })
}

# ============ MAIN SCRIPT LOGIC ============

message("Checking ICE website for updates...")

# Get page
url <- "https://www.ice.gov/detain/detention-management"
page <- read_html(url)

# Find download link
download_link <- page %>%
  html_nodes("a[href*='.xlsx'], a[href*='.xls']") %>%
  html_attr("href") %>%
  .[str_detect(., "(?i)(detention|FY.*202*|alternatives)")] %>%
  first()

if (is.na(download_link)) {
  message("No download link found")
  quit(status = 1)
}

original_filename <- basename(download_link)
message("Found file on website: ", original_filename)

# Check if file already exists in Box
existing_file <- verify_box_upload(original_filename)
if (!is.logical(existing_file) || existing_file != FALSE) {
  message("File already exists in Box: ", original_filename)

  # Set GitHub outputs for existing file
  cat("ice_updated=false\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
  cat("ice_filename=", original_filename, "\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)

  quit(status = 0)

} else { 

  message("File not found in Box, downloading: ", original_filename)
  
  # Download file
  temp_file <- file.path(tempdir(), original_filename)
  response <- GET(download_link, write_disk(temp_file, overwrite = TRUE))
  
  if (status_code(response) != 200) {
    message("Failed to download file. Status code: ", status_code(response))
    quit(status = 1)
  }
  
  message("Downloaded file to: ", temp_file)
  
  # Upload to Box
  upload_result <- upload_to_box(temp_file)
  if (is.logical(upload_result) && !upload_result) {
    message("Box upload failed")
    quit(status = 1)
  }
  
  # Verify upload
  verification <- verify_box_upload(original_filename)
  if (is.logical(verification) && !verification) {
    message("Upload verification failed")
    quit(status = 1)
  }
  
  # Clean up
  unlink(temp_file)

}

message("Successfully processed ICE update: ", original_filename)