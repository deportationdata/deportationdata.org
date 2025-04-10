# keyring::key_set("deepl", prompt = "API key:")
Sys.setenv(DEEPL_API_KEY = keyring::key_get("deepl"))

babeldown::deepl_translate(
  path = "team.qmd",
  out_path = "team.es.qmd",
  source_lang = "EN",
  target_lang = "ES",
  formality = "default"
)
