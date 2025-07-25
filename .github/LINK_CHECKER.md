# Link Checker

This repository includes an automated link checker that runs weekly to monitor the website for broken links.

## How it works

The link checker uses [muffet](https://github.com/raviqqe/muffet), a fast and reliable link checker written in Go, to:

1. **Crawls the website**: Starting from https://deportationdata.org, it recursively follows all internal links
2. **Checks link status**: Tests each discovered link for HTTP status codes and connection errors
3. **Reports broken links**: Creates GitHub issues for any links that return 4xx or 5xx status codes or connection errors
4. **Prevents duplicates**: Checks for existing issues before creating new ones

## Benefits of using muffet

- **Fast and efficient**: Written in Go, much faster than custom Python crawlers
- **Battle-tested**: Widely used in production environments
- **Smart rate limiting**: Built-in respectful crawling with configurable limits
- **Comprehensive checks**: Handles redirects, timeouts, and various error conditions
- **Flexible configuration**: Easy to exclude patterns and configure behavior

## Schedule

The link checker runs automatically:
- **Weekly**: Every Monday at 9:00 AM UTC
- **Manual**: Can be triggered manually from the Actions tab

## Files

- `.github/workflows/check-links.yml`: GitHub Actions workflow
- `.github/scripts/check-links.sh`: Shell script that runs muffet and processes results
- `.github/scripts/create-issues.sh`: Shell script that creates GitHub issues using GitHub CLI
- `.github/scripts/exclude-patterns.txt`: Patterns to exclude from link checking

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

## Configuration

The link checker is configured to:
- Follow internal links only (within deportationdata.org domain)
- Rate limit requests (0.5 seconds between requests)
- Use max 5 concurrent connections with 2 per host
- Exclude common file types (CSS, JS, images, etc.)
- Ignore fragments (#anchors) and mailto/tel links
- Follow robots.txt

## Limitations

- Only checks internal links (within deportationdata.org domain)
- Rate limited to be respectful of server resources
- Skips fragments (#anchors) and mailto/tel links
- Excludes common asset file types to focus on content links