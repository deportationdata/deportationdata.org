# ICE Detention Management Data Scraper
# Scrapes https://www.ice.gov/detain/detention-management for updates

library(rvest)
library(httr)
library(lubridate)
library(stringr)
library(dplyr)
library(boxr)
library(here)

#' Check if ICE detention page was updated today
#' @return List with updated (logical), last_updated_date (Date), and download_url (character)
check_ice_updates <- function() {
  url <- "https://www.ice.gov/detain/detention-management"
  
  tryCatch({
    # Read the webpage
    page <- read_html(url)
    
    # Look for "Last Updated" text - will need to adjust selector based on actual HTML
    # This is a common pattern on government sites
    # Look for time element that's near "Updated:" text
    time_element <- page %>%
      html_nodes(xpath = "//text()[contains(., 'Updated:')]/following-sibling::time | //text()[contains(., 'Updated:')]/..//time")
    
    if (length(time_element) > 0) {
      time_element <- time_element[[1]]
    }
    
    if (length(time_element) > 0) {
      # Get the datetime attribute or the text content
      last_updated_text <- html_attr(time_element, "datetime")
      if (is.na(last_updated_text)) {
        last_updated_text <- html_text(time_element)
      }
    } 
    
    # Extract date from the text
    date_pattern <- "\\b\\w+\\s+\\d{1,2},\\s+\\d{4}\\b|\\b\\d{1,2}/\\d{1,2}/\\d{4}\\b|\\b\\d{4}-\\d{2}-\\d{2}\\b|\\d{4}-\\d{2}-\\d{2}T"
    extracted_date <- str_extract(last_updated_text, "\\d{4}-\\d{2}-\\d{2}")
    
    if (is.na(extracted_date)) {
      warning("Could not extract date from: ", last_updated_text)
      return(list(updated = FALSE, last_updated_date = NA, download_url = NA))
    }
    
    # Parse the date
    last_updated_date <- ymd(extracted_date)
    
    # Check if it's today
    is_today <- !is.na(last_updated_date) && last_updated_date == Sys.Date()
    
    # Look for the specific download link mentioned in requirements
    # "Detention FY 2025 YTD, Alternatives to Detention FY 2025 YTD and Facilities FY 2025 YTD, Footnotes (227 KB)"
    download_link <- page %>%
      html_nodes("a[href*='.xlsx'], a[href*='.xls']") %>%
      html_attr("href") %>%
      .[str_detect(., "(?i)(detention|FY.*2025|alternatives)")] %>%
      first()
    
    return(list(
      updated = is_today,
      last_updated_date = last_updated_date,
      download_url = download_link,
      last_updated_text = last_updated_text
    ))
    
  }, error = function(e) {
    warning("Error checking ICE updates: ", e$message)
    return(list(updated = FALSE, last_updated_date = NA, download_url = NA))
  })
}

#' Download file from ICE website
#' @param url URL to download from
#' @param dest_path Local path to save file
download_ice_file <- function(url, dest_path) {
  if (is.na(url)) {
    stop("No download URL provided")
  }
  
  # Download the file
  response <- GET(url, write_disk(dest_path, overwrite = TRUE))
  
  if (status_code(response) == 200) {
    message("Successfully downloaded file to: ", dest_path)
    return(TRUE)
  } else {
    warning("Failed to download file. Status code: ", status_code(response))
    return(FALSE)
  }
}

#' Upload file to Box using boxr
#' @param local_path Path to local file
#' @param box_path Path in Box (deportationdata/ICE/detention_management)
#' @param filename Original filename to use in Box
upload_to_box <- function(local_path, box_path = "deportationdata/ICE/detention_management", filename = NULL) {
  
  # Check for required environment variables
  required_vars <- c("BOX_CLIENT_ID", "BOX_CLIENT_SECRET")
  missing_vars <- required_vars[!nzchar(Sys.getenv(required_vars))]
  
  if (length(missing_vars) > 0) {
    warning("Missing Box environment variables: ", paste(missing_vars, collapse = ", "))
    return(FALSE)
  }
  
  # Authenticate with Box
  tryCatch({
    # Use environment variables for authentication
    boxr::box_auth_service(
      box_client_id = Sys.getenv("BOX_CLIENT_ID"),
      box_client_secret = Sys.getenv("BOX_CLIENT_SECRET")
    )
    
    # Use original filename if not specified
    if (is.null(filename)) {
      filename <- basename(local_path)
    }
    
    # Try to find or create the directory structure
    # Navigate to deportationdata folder
    deportation_folder <- boxr::box_search("deportationdata", type = "folder")
    if (length(deportation_folder) == 0) {
      warning("deportationdata folder not found in Box")
      return(FALSE)
    }
    
    # Navigate to ICE subfolder
    ice_folder <- boxr::box_search("ICE", type = "folder", ancestor_folder_ids = deportation_folder[[1]]$id)
    if (length(ice_folder) == 0) {
      message("Creating ICE folder")
      ice_folder <- boxr::box_dir_create("ICE", parent_dir_id = deportation_folder[[1]]$id)
    }
    
    # Navigate to detention_management subfolder
    ice_folder_id <- if (is.list(ice_folder)) ice_folder[[1]]$id else ice_folder$id
    detention_folder <- boxr::box_search("detention_management", type = "folder", ancestor_folder_ids = ice_folder_id)
    if (length(detention_folder) == 0) {
      message("Creating detention_management folder")
      detention_folder <- boxr::box_dir_create("detention_management", parent_dir_id = ice_folder_id)
    }
    
    # Upload the file
    detention_folder_id <- if (is.list(detention_folder)) detention_folder[[1]]$id else detention_folder$id
    upload_result <- boxr::box_ul(file = local_path, 
                                  dir_id = detention_folder_id, 
                                  file_name = filename)
    
    message("Successfully uploaded file to Box: ", filename)
    return(upload_result)
    
  }, error = function(e) {
    warning("Failed to upload to Box: ", e$message)
    return(FALSE)
  })
}

#' Verify Box file can be downloaded
#' @param filename Filename in Box
#' @param box_path Path in Box 
verify_box_download <- function(filename, box_path = "deportationdata/ICE/detention_management") {
  tryCatch({
    # Search for the file in Box
    file_search <- boxr::box_search(filename, type = "file")
    
    if (length(file_search) > 0) {
      # Try to get download URL or info
      file_info <- file_search[[1]]
      
      # Check if file exists and is accessible
      if (!is.null(file_info$id)) {
        message("Box file verified and accessible: ", filename)
        message("File ID: ", file_info$id)
        return(file_info)
      }
    }
    
    warning("Could not verify Box download for: ", filename)
    return(FALSE)
    
  }, error = function(e) {
    warning("Error verifying Box download: ", e$message)
    return(FALSE)
  })
}

#' Main function to check for updates and process them
process_ice_updates <- function() {
  message("Checking ICE website for updates...")
  
  # Check if there are updates
  update_info <- check_ice_updates()
  
  if (!update_info$updated) {
    message("No updates found for today.")
    return(list(success = FALSE, message = "No updates"))
  }
  
  message("Update found! Last updated: ", update_info$last_updated_date)
  
  # Create temporary filename with date
  temp_file <- file.path(tempdir(), paste0("ice_detention_", 
                                           format(update_info$last_updated_date, "%Y%m%d"), 
                                           ".xlsx"))
  
  # Download the file
  if (!download_ice_file(update_info$download_url, temp_file)) {
    return(list(success = FALSE, message = "Download failed"))
  }
  
  # Check if file already exists in Box before uploading
  original_filename <- basename(update_info$download_url)
  
  # Check if file already exists in Box
  existing_file <- verify_box_download(original_filename)
  if (!is.logical(existing_file) || existing_file != FALSE) {
    message("File already exists in Box: ", original_filename)
    unlink(temp_file)
    return(list(
      success = TRUE,
      message = "File already exists in Box - no upload needed",
      date = update_info$last_updated_date,
      filename = original_filename,
      box_file_info = existing_file
    ))
  } else { 
    # Upload to Box with original filename
    box_result <- upload_to_box(temp_file, filename = original_filename)
    if (is.logical(box_result) && !box_result) {
      return(list(success = FALSE, message = "Box upload failed"))
    }
    # Verify Box download
    box_file_info <- verify_box_download(original_filename)
    if (is.logical(box_file_info) && !box_file_info) {
      return(list(success = FALSE, message = "Box verification failed"))
    }
    # Clean up temp file
    unlink(temp_file)
      return(list(
      success = TRUE, 
      message = "Successfully processed ICE update",
      date = update_info$last_updated_date,
      filename = original_filename,
      box_file_info = box_file_info
   ))
  }
  
}

# Function to be called by GitHub Action
main <- function() {
  result <- process_ice_updates()
  
  if (result$success) {
    message("SUCCESS: ", result$message)
    message("Date: ", result$date)
    message("Filename: ", result$filename)
    
    # Output for GitHub Action
    cat("ice_updated=true\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
    cat("ice_date=", as.character(result$date), "\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
    cat("ice_filename=", result$filename, "\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
    
    # Save box file info to a temporary file for the next step
    if (!is.null(result$box_file_info)) {
      box_info_file <- tempfile(fileext = ".rds")
      saveRDS(result$box_file_info, box_info_file)
      cat("box_info_file=", box_info_file, "\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
    }
  } else {
    message("NO UPDATE: ", result$message)
    cat("ice_updated=false\n", file = Sys.getenv("GITHUB_OUTPUT", ""), append = TRUE)
  }
}

# Run main if script is executed directly
if (!interactive()) {
  main()
}