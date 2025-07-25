#!/bin/bash
set -e

echo "=== DeportationData.org Link Checker (using lychee) ==="

# Configuration
BASE_URL="https://deportationdata.org"
RESULTS_FILE="/tmp/lychee_results.json"

# Run lychee to check links
echo "Running lychee to check links on $BASE_URL..."

# Lychee configuration:
# --format=json: Output in JSON format for parsing
# --verbose: Show detailed output
# --no-progress: Don't show progress bar (better for CI)
# --max-redirects=5: Follow up to 5 redirects
# --timeout=10: 10 second timeout per request
# --max-concurrency=4: Limit concurrent requests
# --include-verbatim: Check external links found on pages (but don't crawl them)
# --exclude: Skip file extensions and problematic URLs
lychee \
  --format=json \
  --verbose \
  --no-progress \
  --max-redirects=5 \
  --timeout=10 \
  --max-concurrency=4 \
  --include-verbatim \
  --exclude=".*\.(css|js|png|jpg|jpeg|gif|pdf|zip|xml|ico|svg|woff|woff2|ttf|eot)$" \
  --exclude="mailto:.*" \
  --exclude="tel:.*" \
  --exclude=".*facebook\.com.*" \
  --exclude=".*twitter\.com.*" \
  --exclude=".*linkedin\.com.*" \
  --exclude=".*instagram\.com.*" \
  --exclude=".*\?.*utm_.*" \
  "$BASE_URL" > "$RESULTS_FILE" 2>&1 || true

echo "Lychee check complete. Processing results..."

# Check if results file exists and has content
if [ ! -f "$RESULTS_FILE" ] || [ ! -s "$RESULTS_FILE" ]; then
    echo "✅ No broken links found!"
    exit 0
fi

# Process results and create GitHub issues using GitHub CLI
echo "Processing results and creating GitHub issues..."
bash .github/scripts/create-issues.sh "$RESULTS_FILE"

echo "Link checking complete!"