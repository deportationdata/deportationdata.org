#!/bin/bash
set -e

# GitHub issue creator for broken links found by muffet.
# Processes muffet JSON output and creates GitHub issues using GitHub CLI.

RESULTS_FILE="$1"

if [ -z "$RESULTS_FILE" ]; then
    echo "Usage: $0 <muffet_results_file>"
    exit 1
fi

if [ ! -f "$RESULTS_FILE" ] || [ ! -s "$RESULTS_FILE" ]; then
    echo "✅ No broken links found!"
    exit 0
fi

echo "Processing muffet results from: $RESULTS_FILE"

# Function to check if issue already exists for a broken URL
check_existing_issue() {
    local broken_url="$1"
    local existing_issues
    
    # Search for existing open issues with the broken URL and broken-link label
    existing_issues=$(gh issue list --state=open --label="broken-link" --search="\"$broken_url\"" --json number --jq length 2>/dev/null || echo 0)
    
    [ "$existing_issues" -gt 0 ]
}

# Function to create GitHub issue using gh CLI
create_github_issue() {
    local broken_url="$1"
    local source_page="$2"
    local error_msg="$3"
    
    # Check if issue already exists
    if check_existing_issue "$broken_url"; then
        echo "Issue already exists for $broken_url, skipping..."
        return 0
    fi
    
    local title="Broken link found: $broken_url"
    
    # Create issue body
    local body="A broken link was detected on the website by the automated link checker.

**Broken URL:** $broken_url
**Found on page:** $source_page
**Error:** $error_msg

**Details:**
This issue was automatically created by the link checker workflow using [muffet](https://github.com/raviqqe/muffet).

Please check the link and either fix it or remove it from the source page.

---
*This issue was created automatically by the [Check Website Links workflow](https://github.com/$GITHUB_REPOSITORY/actions/workflows/check-links.yml)*"
    
    # Create the issue using GitHub CLI
    if gh issue create \
        --title "$title" \
        --body "$body" \
        --label "bug,broken-link,automated" > /dev/null 2>&1; then
        
        echo "Created issue for: $broken_url"
        return 0
    else
        echo "Failed to create issue for: $broken_url"
        return 1
    fi
}

# Parse muffet JSON output and create issues
broken_count=0
created_count=0

echo "Parsing muffet output..."

while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue
    
    # Try to parse JSON line
    if echo "$line" | jq . > /dev/null 2>&1; then
        # Check if this line contains an error
        if echo "$line" | jq -e '.error' > /dev/null 2>&1; then
            broken_url=$(echo "$line" | jq -r '.url // "Unknown"')
            source_page=$(echo "$line" | jq -r '.source // "Unknown"')
            error_msg=$(echo "$line" | jq -r '.error // "Unknown error"')
            
            if [ "$broken_url" != "Unknown" ]; then
                echo "Processing broken link: $broken_url"
                broken_count=$((broken_count + 1))
                
                if create_github_issue "$broken_url" "$source_page" "$error_msg"; then
                    created_count=$((created_count + 1))
                fi
                
                # Rate limiting - wait 1 second between GitHub API calls
                sleep 1
            fi
        fi
    fi
done < "$RESULTS_FILE"

if [ $broken_count -eq 0 ]; then
    echo "✅ No broken links found!"
else
    echo "Found $broken_count broken links"
    echo "Created $created_count GitHub issues for broken links"
fi