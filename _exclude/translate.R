# keyring::key_set("deepl", prompt = "API key:")
Sys.setenv(DEEPL_API_KEY = keyring::key_get("deepl"))

babeldown::deepl_translate(
  path = "reports.qmd",
  out_path = "reportes.es.qmd",
  source_lang = "EN",
  target_lang = "ES",
  formality = "default"
)

babeldown::deepl_translate(
  path = "foia.qmd",
  out_path = "foia.es.qmd",
  source_lang = "EN",
  target_lang = "ES",
  formality = "default"
)
