#!/bin/bash
set -e

echo "=== DeportationData.org Link Checker (using wget + lychee) ==="

# -------------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------------
BASE_URL="https://deportationdata.org"
RESULTS_FILE="/tmp/lychee_results.json"       # machine-readable JSON
URLS_FILE="/tmp/crawled_urls.txt"             # one URL per line
WGET_LOG="/tmp/wget.log"                      # raw wget debug log
LYCHEE_LOG="/tmp/lychee_verbose.log"          # human-readable lychee log

# -------------------------------------------------------------------------
# Step 1 – Crawl the site (wget spider) to build URL list
# -------------------------------------------------------------------------
echo "Crawling $BASE_URL to discover all pages..."

echo "Attempting wget spider crawl..."
if wget \
    --spider \
    --recursive \
    --level=inf \
    --no-parent \
    --domains=deportationdata.org \
    --reject="css,js,png,jpg,jpeg,gif,pdf,zip,xml,ico,svg,woff,woff2,ttf,eot,rss,atom" \
    --output-file="$WGET_LOG" \
    --debug \
    "$BASE_URL" 2>&1; then
  echo "wget crawl successful"
else
  echo "wget completed with status $? (may be normal for spider mode)"
fi

# -------------------------------------------------------------------------
# Extract URLs from wget log
# -------------------------------------------------------------------------
if [[ -s "$WGET_LOG" ]]; then
  echo "Extracting URLs from wget debug output…"

  {
    # Direct URLs
    grep -o 'https://deportationdata\.org[^[:space:]"'\''"]*' "$WGET_LOG" || true
    # Enqueuing lines
    grep "Enqueuing"      "$WGET_LOG" | grep -o 'https://deportationdata\.org[^[:space:]"'\''"]*' || true
    # IRI Enqueuing lines
    grep "IRI Enqueuing"  "$WGET_LOG" | grep -o 'https://deportationdata\.org[^[:space:]"'\''"]*' || true
  } | \
  grep -v '\.\(css\|js\|png\|jpg\|jpeg\|gif\|pdf\|zip\|xml\|ico\|svg\|woff\|woff2\|ttf\|eot\|rss\|atom\)\(\?.*\)\?$' | \
  sed 's/['\''",;)]*$//g' | \
  grep -E '^https://deportationdata\.org/[^[:space:]"'\''"]+$' | \
  sort -u > "${URLS_FILE}.tmp"

  # Always include the root URL
  printf "%s\n%s/\n" "$BASE_URL" "$BASE_URL" >> "${URLS_FILE}.tmp"
  sort -u "${URLS_FILE}.tmp" > "$URLS_FILE"
  rm -f "${URLS_FILE}.tmp"
else
  echo "wget log empty – falling back to root URL only."
  printf "%s\n" "$BASE_URL" > "$URLS_FILE"
fi

# -------------------------------------------------------------------------
# Optional curl fallback if very few URLs found
# -------------------------------------------------------------------------
URL_COUNT=$(wc -l < "$URLS_FILE" || echo 0)
if (( URL_COUNT < 5 )); then
  echo "Low URL count ($URL_COUNT).  Trying curl-based discovery…"
  curl -sL --max-time 30 "$BASE_URL" | \
    grep -o 'href="[^"]*"' | \
    grep -o '"[^"]*deportationdata\.org[^"]*"' | \
    tr -d '"' >> "$URLS_FILE" || true
  printf "%s\n" "$BASE_URL" >> "$URLS_FILE"
  sort -u "$URLS_FILE" -o "$URLS_FILE"
fi

URL_COUNT=$(wc -l < "$URLS_FILE" || echo 0)
echo "Discovered $URL_COUNT pages to check."
head -n 10 "$URLS_FILE"
(( URL_COUNT > 10 )) && echo "... (and $((URL_COUNT - 10)) more)"

[[ $URL_COUNT -eq 0 ]] && { echo "No URLs discovered; aborting."; exit 1; }

# -------------------------------------------------------------------------
# Step 2 – Run lychee against the list
# -------------------------------------------------------------------------
echo
echo "Running lychee…"

LYCHEE_CMD="lychee"
command -v lychee >/dev/null 2>&1 || LYCHEE_CMD="./lychee"

if ! [[ -x $(command -v "$LYCHEE_CMD") ]]; then
  echo "Error: lychee binary not found or not executable."; exit 1
fi

$LYCHEE_CMD \
  --format=json \
  --no-progress \
  --max-redirects=5 \
  --timeout=10 \
  --max-concurrency=4 \
  --include-verbatim \
  --exclude='.*\.\(css\|js\|png\|jpg\|jpeg\|gif\|pdf\|zip\|xml\|ico\|svg\|woff\|woff2\|ttf\|eot\)(\?.*)?$' \
  --exclude='mailto:.*' \
  --exclude='tel:.*' \
  --exclude='.*facebook\.com.*' \
  --exclude='.*twitter\.com.*' \
  --exclude='.*linkedin\.com.*' \
  --exclude='.*instagram\.com.*' \
  --exclude='.*\?.*utm_.*' \
  --input "$URLS_FILE" \
  >"$RESULTS_FILE" 2>"$LYCHEE_LOG" || true

echo "Lychee finished.  Verbose log → $LYCHEE_LOG"

# -------------------------------------------------------------------------
# Step 3 – Post-process results
# -------------------------------------------------------------------------
if [[ ! -s "$RESULTS_FILE" ]]; then
  echo "✅  No broken links found!"
  exit 0
fi

echo "Processing results and creating GitHub issues…"
bash .github/scripts/create-issues.sh "$RESULTS_FILE"

echo "Link checking complete!"