# Link Checker

This repository includes an automated link checker that runs weekly to monitor the website for broken links.

## How it works

The link checker:

1. **Crawls the website**: Starting from https://deportationdata.org, it recursively follows all internal links
2. **Checks link status**: Tests each discovered link for HTTP status codes
3. **Reports broken links**: Creates GitHub issues for any links that return 4xx or 5xx status codes or connection errors
4. **Prevents duplicates**: Checks for existing issues before creating new ones

## Schedule

The link checker runs automatically:
- **Weekly**: Every Monday at 9:00 AM UTC
- **Manual**: Can be triggered manually from the Actions tab

## Files

- `.github/workflows/check-links.yml`: GitHub Actions workflow
- `.github/scripts/check-links.py`: Python script that performs the link checking

## Issue labels

Issues created by the link checker are tagged with:
- `bug`: Indicates a problem that needs fixing
- `broken-link`: Specifically identifies link-related issues  
- `automated`: Shows the issue was created automatically

## Manual execution

To run the link checker manually:

1. Go to the **Actions** tab in GitHub
2. Select **Check Website Links** 
3. Click **Run workflow**

## Limitations

- Crawls up to 50 pages to prevent excessive load
- Only checks internal links (within deportationdata.org domain)
- Rate limited to be respectful of server resources
- Skips fragments (#anchors) and mailto/tel links