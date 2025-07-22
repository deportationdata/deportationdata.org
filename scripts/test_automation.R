#!/usr/bin/env Rscript

# Test script for ICE detention data automation
# This script tests the report updating functionality without requiring Box API access

library(stringr)
library(lubridate)

# Source the update functions
source("scripts/update_reports.R")

test_report_update <- function() {
  cat("Testing report update functionality...\n")
  
  # Create test date and filename
  test_date <- Sys.Date()
  test_filename <- paste0("detention_fy2025_", format(test_date, "%Y%m%d"), ".xlsx")
  
  # Generate test Box URL
  test_box_url <- "https://ucla.box.com/shared/static/testabc123def456.xlsx"
  
  # Create backup copies of the original files
  file.copy("data/reports.qmd", "data/reports.qmd.backup")
  file.copy("data/reports.es.qmd", "data/reports.es.qmd.backup")
  
  tryCatch({
    cat("Testing English file update...\n")
    en_result <- update_reports_file("data/reports.qmd", test_date, test_filename, test_box_url)
    
    cat("Testing Spanish file update...\n")  
    es_result <- update_reports_file("data/reports.es.qmd", test_date, test_filename, test_box_url)
    
    if (en_result && es_result) {
      cat("✅ Report update test PASSED\n")
      
      # Show what was added to the English file
      content <- readLines("data/reports.qmd")
      tribble_start <- which(grepl("ice_detention_management_ytd_files", content))
      if (length(tribble_start) > 0) {
        cat("\nFirst few lines of updated English tribble:\n")
        print(content[(tribble_start + 3):(tribble_start + 6)])
      }
      
      return(TRUE)
    } else {
      cat("❌ Report update test FAILED\n")
      return(FALSE)
    }
    
  }, error = function(e) {
    cat("❌ Error during test:", e$message, "\n")
    return(FALSE)
    
  }, finally = {
    # Restore original files
    cat("Restoring original files...\n")
    file.copy("data/reports.qmd.backup", "data/reports.qmd", overwrite = TRUE)
    file.copy("data/reports.es.qmd.backup", "data/reports.es.qmd", overwrite = TRUE)
    
    # Clean up backup files
    file.remove("data/reports.qmd.backup")
    file.remove("data/reports.es.qmd.backup")
  })
}

# Test the scraper pattern matching (without actually scraping)
test_scraper_patterns <- function() {
  cat("Testing scraper pattern matching...\n")
  
  # Test date extraction patterns
  test_texts <- c(
    "Last Updated: July 22, 2025",
    "last updated July 22, 2025",
    "Updated on 07/22/2025",
    "Last Modified: 2025-07-22"
  )
  
  date_pattern <- "\\b\\w+\\s+\\d{1,2},\\s+\\d{4}\\b|\\b\\d{1,2}/\\d{1,2}/\\d{4}\\b|\\b\\d{4}-\\d{2}-\\d{2}\\b"
  
  all_passed <- TRUE
  for (text in test_texts) {
    extracted <- str_extract(text, date_pattern)
    if (is.na(extracted)) {
      cat("❌ Failed to extract date from:", text, "\n")
      all_passed <- FALSE
    } else {
      cat("✅ Extracted '", extracted, "' from '", text, "'\n")
    }
  }
  
  return(all_passed)
}

# Run all tests
main_test <- function() {
  cat("=== ICE Detention Data Automation Tests ===\n\n")
  
  # Check if required files exist
  required_files <- c("data/reports.qmd", "data/reports.es.qmd", "scripts/update_reports.R")
  missing_files <- required_files[!file.exists(required_files)]
  
  if (length(missing_files) > 0) {
    cat("❌ Missing required files:", paste(missing_files, collapse = ", "), "\n")
    return(FALSE)
  }
  
  # Run tests
  pattern_test <- test_scraper_patterns()
  cat("\n")
  
  report_test <- test_report_update()
  cat("\n")
  
  if (pattern_test && report_test) {
    cat("🎉 All tests PASSED! The automation should work correctly.\n")
    return(TRUE)
  } else {
    cat("❌ Some tests FAILED. Please review the code before deployment.\n")
    return(FALSE)
  }
}

# Run if executed directly
if (!interactive()) {
  success <- main_test()
  if (!success) {
    quit(status = 1)
  }
}