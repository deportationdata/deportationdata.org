library(tidyverse)
library(xml2)

feed_url <- "https://www.google.com/alerts/feeds/02955532534013716982/12087324954695823875"
rss_file <- "rss_items.rds"

new_items <- read_xml(feed_url) |>
  xml_find_all("//item") |>
  map_df(~ tibble(
    title = xml_text(xml_find_first(.x, "title")),
    link = xml_text(xml_find_first(.x, "link")),
    pubDate = xml_text(xml_find_first(.x, "pubDate"))
  ))

if (file.exists(rss_file)) {
  old_items <- read_rds(rss_file)
  is_new <- !new_items$link %in% old_items$link
  if (any(is_new)) {
    saveRDS(new_items, rss_file)
    quit(status = 0)  # success = trigger commit
  } else {
    quit(status = 1)  # no update
  }
} else {
  write_rds(new_items, path = rss_file)
  quit(status = 0)
}