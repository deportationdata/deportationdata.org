#!/bin/bash
set -e

echo "=== DeportationData.org Link Checker (using muffet) ==="

# Configuration
BASE_URL="https://deportationdata.org"
RESULTS_FILE="/tmp/muffet_results.json"

# Run muffet to check links
echo "Running muffet to check links on $BASE_URL..."
muffet \
  --format=json \
  --max-connections=5 \
  --max-connections-per-host=2 \
  --rate-limit=0.5 \
  --timeout=10 \
  --buffer-size=8192 \
  --exclude=".*\.(css|js|png|jpg|jpeg|gif|pdf|zip|xml|ico|svg|woff|woff2|ttf|eot)$" \
  --exclude="mailto:.*" \
  --exclude="tel:.*" \
  --exclude="#.*" \
  --ignore-fragments \
  --follow-robots-txt \
  --exclude-patterns-from-file=.github/scripts/exclude-patterns.txt \
  "$BASE_URL" > "$RESULTS_FILE" 2>&1 || true

echo "Muffet check complete. Processing results..."

# Check if results file exists and has content
if [ ! -f "$RESULTS_FILE" ] || [ ! -s "$RESULTS_FILE" ]; then
    echo "✅ No broken links found!"
    exit 0
fi

# Process results and create GitHub issues
echo "Processing results and creating GitHub issues..."
python3 .github/scripts/create-issues.py "$RESULTS_FILE"

echo "Link checking complete!"