# Test script for update_reports functionality
# This tests the report updating logic

library(stringr)
library(lubridate)

# Test the pattern matching and replacement logic
test_update_logic <- function() {
  
  # Read the current reports.qmd file
  content <- readLines("data/reports.qmd")
  content_str <- paste(content, collapse = "\n")
  
  # Find the ice_detention_management_ytd_files tibble
  pattern <- "(ice_detention_management_ytd_files <-\\s*tibble::tribble\\(\\s*~Start,\\s*~End,\\s*~Source,\\s*~Download,\\s*)(.*?)(\\s*\\))"
  
  matches <- str_match(content_str, pattern)
  
  if (!is.na(matches[1])) {
    cat("Successfully found the tibble pattern\n")
    cat("Data section preview:\n")
    data_section <- matches[3]
    data_lines <- head(strsplit(data_section, "\n")[[1]], 3)
    cat(paste(data_lines, collapse = "\n"), "\n")
  } else {
    cat("Pattern not found - need to adjust regex\n")
  }
  
  # Test with a simpler approach - find the tribble start and end
  tribble_start <- str_locate(content_str, "ice_detention_management_ytd_files <-\\s*tibble::tribble\\(")[2]
  if (!is.na(tribble_start)) {
    cat("\nFound tribble start at position:", tribble_start, "\n")
    
    # Find the matching closing parenthesis
    remaining <- substr(content_str, tribble_start + 1, nchar(content_str))
    paren_count <- 1
    pos <- 1
    
    while (paren_count > 0 && pos <= nchar(remaining)) {
      char <- substr(remaining, pos, pos)
      if (char == "(") paren_count <- paren_count + 1
      if (char == ")") paren_count <- paren_count - 1
      pos <- pos + 1
    }
    
    if (paren_count == 0) {
      tribble_end <- tribble_start + pos
      cat("Found tribble end at position:", tribble_end, "\n")
      
      # Extract the data
      tribble_content <- substr(content_str, tribble_start + 1, tribble_end - 2)
      cat("Extracted tribble content (first 200 chars):\n")
      cat(substr(tribble_content, 1, 200), "...\n")
    }
  }
}

# Run the test
test_update_logic()