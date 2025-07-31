library(tidyverse)
library(xml2)
library(jsonlite)

feed_url <- "https://www.google.com/alerts/feeds/02955532534013716982/12087324954695823875"
json_file <- "news_feed.json"

# Read XML and register namespaces
doc <- read_xml(feed_url)
ns <- xml_ns(doc)  # Will include "d1" -> Atom namespace

# Extract Atom <entry> elements
entries <- xml_find_all(doc, ".//d1:entry", ns)

# Parse entries to tibble
new_items <- map_df(entries, ~ tibble(
  title = xml_text(xml_find_first(.x, "d1:title", ns)),
  link  = xml_attr(xml_find_first(.x, "d1:link", ns), "href"),
  published = xml_text(xml_find_first(.x, "d1:published", ns))
)) |>
  distinct(link, .keep_all = TRUE)

# If no entries, quit safely
if (nrow(new_items) == 0) {
  message("No entries found in feed.")
  quit(status = 0)
}

# Load existing JSON if it exists
if (file.exists(json_file)) {
  old_items <- fromJSON(json_file, simplifyDataFrame = TRUE)
  new_only <- anti_join(new_items, old_items, by = "link")

  if (nrow(new_only) > 0) {
    updated <- bind_rows(new_only, old_items) |>
      arrange(desc(published))
    write_json(updated, json_file, pretty = TRUE, auto_unbox = TRUE)
    quit(status = 1)  # trigger commit
  } else {
    message("No new items.")
    quit(status = 0)
  }

} else {
  # First-time save
  write_json(new_items, json_file, pretty = TRUE, auto_unbox = TRUE)
  quit(status = 1)
}
