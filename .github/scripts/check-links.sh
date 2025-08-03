#!/bin/bash
set -e

echo "=== DeportationData.org Link Checker (using wget + lychee) ==="

# Configuration
BASE_URL="https://deportationdata.org"
RESULTS_FILE="/tmp/lychee_results.json"
URLS_FILE="/tmp/crawled_urls.txt"
WGET_LOG="/tmp/wget.log"

# Step 1: Crawl the website to discover all pages
echo "Crawling $BASE_URL to discover all pages..."

# Method 1: Try wget first (more comprehensive crawling)
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

# Extract URLs from wget debug output
if [ -f "$WGET_LOG" ] && [ -s "$WGET_LOG" ]; then
    echo "Extracting URLs from wget debug output..."
    
    # Extract URLs from multiple patterns in wget debug output
    {
        # Pattern 1: Direct URLs
        grep -o 'https://deportationdata\.org[^[:space:]"'\'']*' "$WGET_LOG" 2>/dev/null || true
        
        # Pattern 2: Enqueuing lines  
        grep "Enqueuing" "$WGET_LOG" 2>/dev/null | grep -o 'https://deportationdata\.org[^[:space:]"'\'']*' || true
        
        # Pattern 3: IRI Enqueuing lines
        grep "IRI Enqueuing" "$WGET_LOG" 2>/dev/null | grep -o 'https://deportationdata\.org[^[:space:]"'\'']*' || true
    } | \
    # Remove file extensions we don't want to check and clean up URLs
    grep -v '\.(css|js|png|jpg|jpeg|gif|pdf|zip|xml|ico|svg|woff|woff2|ttf|eot|rss|atom)(\?.*)?$' | \
    # Remove trailing punctuation and quotes that might be captured
    sed 's/['\''",;)]*$//g' | \
    # Remove URLs that are just punctuation or very short
    grep -E '^https://deportationdata\.org/[^[:space:]\"\'']+$' | \
    # Remove empty lines
    grep -v '^$' | \
    sort -u > "$URLS_FILE.tmp"
    
    # Ensure we have at least the base URL
    echo "$BASE_URL" >> "$URLS_FILE.tmp"
    echo "$BASE_URL/" >> "$URLS_FILE.tmp"
    sort -u "$URLS_FILE.tmp" > "$URLS_FILE"
    rm -f "$URLS_FILE.tmp"
else
    echo "wget log not found or empty, using base URL only"
    echo "$BASE_URL" > "$URLS_FILE"
fi

# Method 2: If we didn't get many URLs, try a simpler curl-based approach as fallback
URL_COUNT=$(wc -l < "$URLS_FILE" 2>/dev/null || echo "0")
if [ "$URL_COUNT" -lt 5 ]; then
    echo "Low URL count ($URL_COUNT), attempting curl-based page discovery..."
    
    # Get the main page and extract internal links
    if curl -s -L --max-time 30 "$BASE_URL" 2>/dev/null | \
       grep -o 'href="[^"]*"' | \
       grep -o '"[^"]*deportationdata\.org[^"]*"' | \
       sed 's/"//g' > /tmp/curl_urls.txt 2>/dev/null; then
        
        # Add curl-discovered URLs to our list
        cat /tmp/curl_urls.txt >> "$URLS_FILE"
        echo "$BASE_URL" >> "$URLS_FILE"
        sort -u "$URLS_FILE" > "$URLS_FILE.tmp" && mv "$URLS_FILE.tmp" "$URLS_FILE"
    fi
fi

# Final URL count and display
URL_COUNT=$(wc -l < "$URLS_FILE" 2>/dev/null || echo "0")
echo "Discovered $URL_COUNT pages to check:"
if [ "$URL_COUNT" -gt 0 ]; then
    head -10 "$URLS_FILE" 2>/dev/null || true
    if [ "$URL_COUNT" -gt 10 ]; then
        echo "... (and $((URL_COUNT - 10)) more)"
    fi
else
    echo "No URLs discovered. Check network connectivity."
    exit 1
fi

# Step 2: Use lychee to check links on all discovered pages
echo ""
echo "Running lychee to check links on all discovered pages..."

if [ -f "$URLS_FILE" ] && [ -s "$URLS_FILE" ]; then
    # Use lychee from PATH, or fallback to local binary for testing
    LYCHEE_CMD="lychee"
    if ! command -v lychee >/dev/null 2>&1; then
        if [ -f "./lychee" ]; then
            LYCHEE_CMD="./lychee"
        else
            echo "Error: lychee not found in PATH or current directory"
            exit 1
        fi
    fi
    
    # Lychee configuration:
    # --format=json: Output in JSON format for parsing
    # --verbose: Show detailed output
    # --no-progress: Don't show progress bar (better for CI)
    # --max-redirects=5: Follow up to 5 redirects
    # --timeout=10: 10 second timeout per request
    # --max-concurrency=4: Limit concurrent requests
    # --include-verbatim: Check external links found on pages (but don't crawl them)
    # --exclude: Skip file extensions and problematic URLs
    $LYCHEE_CMD \
      --format=json \
      --verbose \
      --no-progress \
      --max-redirects=5 \
      --timeout=10 \
      --max-concurrency=4 \
      --include-verbatim \
      --exclude=".*\.(css|js|png|jpg|jpeg|gif|pdf|zip|xml|ico|svg|woff|woff2|ttf|eot)(\?.*)?$" \
      --exclude="mailto:.*" \
      --exclude="tel:.*" \
      --exclude=".*facebook\.com.*" \
      --exclude=".*twitter\.com.*" \
      --exclude=".*linkedin\.com.*" \
      --exclude=".*instagram\.com.*" \
      --exclude=".*\?.*utm_.*" \
      $(cat "$URLS_FILE" | tr '\n' ' ') > "$RESULTS_FILE" 2>&1 || true
else
    echo "Error: No URLs to check"
    exit 1
fi

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