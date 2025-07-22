# Update reports.qmd files with new ICE detention data
# This script updates both English and Spanish versions

library(stringr)
library(lubridate)
library(readr)

#' Update reports.qmd file with new ICE detention data
#' @param file_path Path to the reports.qmd file
#' @param new_date Date of the new report (Date object)
#' @param new_filename Name of the file in Box
#' @param new_box_url URL to the file in Box (to be generated)
update_reports_file <- function(file_path, new_date, new_filename, new_box_url) {
  
  # Read the file
  content <- read_file(file_path)
  
  # Format the date for display (e.g., "Jul. 7, 2025")
  formatted_date <- format(new_date, "%b. %d, %Y")
  
  # Extract file size from filename if available (placeholder for now)
  file_size <- "TBD"  # Would need to get actual file size
  
  # Find the ice_detention_management_ytd_files tibble with more specific pattern
  # Looking for the pattern from line 48-70 in the file
  tribble_start_pattern <- "ice_detention_management_ytd_files <-\\s*\n\\s*tibble::tribble\\(\n\\s*~Start,\\s*~End,\\s*~Source,\\s*~Download,"
  tribble_end_pattern <- "\\s*\\)"
  
  # Find the start position
  start_match <- str_locate(content, tribble_start_pattern)
  if (is.na(start_match[1])) {
    warning("Could not find ice_detention_management_ytd_files tribble start in ", file_path)
    return(FALSE)
  }
  
  # Find the end position (the closing parenthesis after the data)
  # Start searching after the tribble header
  search_start <- start_match[2] + 1
  remaining_content <- substr(content, search_start, nchar(content))
  
  # Find the line that just contains spaces and a closing parenthesis
  end_match <- str_locate(remaining_content, "\n\\s*\\)")
  if (is.na(end_match[1])) {
    warning("Could not find ice_detention_management_ytd_files tribble end in ", file_path)
    return(FALSE)
  }
  
  # Calculate absolute positions
  tribble_data_start <- start_match[2] + 1
  tribble_data_end <- search_start + end_match[1] - 1
  
  # Extract the current data section
  current_data <- substr(content, tribble_data_start, tribble_data_end)
  
  # Create new first row following the exact format
  # Based on line 51: "Oct. 1, 2024",  "Jul. 7, 2025", "<a href='https://www.ice.gov/detain/detention-management'>ICE</a>", "<a href='https://ucla.box.com/shared/static/7z4bmopvk5ww9uqutgw1pytupltj9hbe.xlsx'>xlsx</a> (1.5 MB)",
  new_row <- sprintf('\n    "Oct. 1, 2024",  "%s", "<a href=\'https://www.ice.gov/detain/detention-management\'>ICE</a>", "<a href=\'%s\'>xlsx</a> (%s)",',
                     formatted_date, new_box_url, file_size)
  
  # Combine new row + existing data
  updated_data <- paste0(new_row, current_data)
  
  # Reconstruct the file
  before_tribble <- substr(content, 1, tribble_data_start - 1)
  after_tribble <- substr(content, tribble_data_end + 1, nchar(content))
  
  updated_content <- paste0(before_tribble, updated_data, after_tribble)
  
  # Write back to file
  write_file(updated_content, file_path)
  
  message("Updated ", file_path, " with new entry dated ", formatted_date)
  return(TRUE)
}

#' Generate Box share URL for the file
#' @param box_file_info File info returned from Box API
#' @return UCLA Box share URL 
generate_box_url <- function(box_file_info) {
  if (is.logical(box_file_info) && !box_file_info) {
    # Fallback to placeholder URL pattern
    hash <- paste0(sample(c(letters, 0:9), 32, replace = TRUE), collapse = "")
    return(paste0("https://ucla.box.com/shared/static/", hash, ".xlsx"))
  }
  
  # If we have actual Box file info, try to generate a share URL
  # This would require additional Box API calls to create a shared link
  # For now, use the placeholder pattern but with file ID
  if (!is.null(box_file_info$id)) {
    # This is a placeholder - in reality, you'd need to call Box API to create shared link
    return(paste0("https://ucla.box.com/shared/static/file_", box_file_info$id, ".xlsx"))
  }
  
  # Final fallback
  hash <- paste0(sample(c(letters, 0:9), 32, replace = TRUE), collapse = "")
  return(paste0("https://ucla.box.com/shared/static/", hash, ".xlsx"))
}

#' Main function to update both English and Spanish reports
#' @param ice_date Date of the ICE update
#' @param ice_filename Name of the ICE file
#' @param box_file_info Box file information from upload
update_reports <- function(ice_date, ice_filename, box_file_info = NULL) {
  
  # Convert string date to Date object if needed
  if (is.character(ice_date)) {
    ice_date <- as.Date(ice_date)
  }
  
  # Generate Box URL 
  box_url <- generate_box_url(box_file_info)
  
  # Update English version
  en_file <- "data/reports.qmd"
  en_success <- update_reports_file(en_file, ice_date, ice_filename, box_url)
  
  # Update Spanish version  
  es_file <- "data/reports.es.qmd"
  es_success <- update_reports_file(es_file, ice_date, ice_filename, box_url)
  
  if (en_success && es_success) {
    message("Successfully updated both English and Spanish reports files")
    return(TRUE)
  } else {
    warning("Failed to update one or more reports files")
    return(FALSE)
  }
}

# Function to be called by GitHub Action
main <- function() {
  # Get arguments from environment variables set by previous step
  ice_date <- Sys.getenv("ICE_DATE")
  ice_filename <- Sys.getenv("ICE_FILENAME")
  box_info_file <- Sys.getenv("BOX_INFO_FILE")
  
  if (ice_date == "" || ice_filename == "") {
    message("No ICE date or filename provided, skipping reports update")
    return()
  }
  
  message("Updating reports with ICE data from ", ice_date)
  
  # Load box file info if available
  box_file_info <- NULL
  if (box_info_file != "" && file.exists(box_info_file)) {
    box_file_info <- readRDS(box_info_file)
  }
  
  success <- update_reports(ice_date, ice_filename, box_file_info)
  
  if (success) {
    message("Reports updated successfully")
    cat("reports_updated=true\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
  } else {
    message("Failed to update reports")
    cat("reports_updated=false\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
  }
}

# Run main if script is executed directly
if (!interactive()) {
  main()
}