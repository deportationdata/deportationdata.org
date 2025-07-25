# Link Checker

This repository includes an automated link checker that runs weekly to monitor the website for broken links.

## How it works

The link checker uses [lychee](https://github.com/lycheeverse/lychee), a fast and reliable link checker written in Rust, to:

1. **Crawls the website**: Starting from https://deportationdata.org, it follows all internal links and checks external links found on pages
2. **Checks all link types**: Tests internal links, external links, and anchor/fragment links for HTTP status codes and connection errors
3. **Reports broken links**: Creates GitHub issues for any links that return 4xx or 5xx status codes or connection errors
4. **Prevents duplicates**: Checks for existing issues before creating new ones

## Benefits of using lychee

- **Fast and efficient**: Written in Rust, extremely fast with excellent performance
- **Comprehensive coverage**: Checks internal links, external links, and anchor/fragment links
- **Smart crawling**: Crawls internal pages but only checks external links (doesn't recurse into external sites)
- **Battle-tested**: Widely used in production environments and actively maintained
- **Flexible configuration**: Easy to exclude patterns and configure behavior
- **Built-in safety**: Respectful crawling with configurable timeouts and concurrency limits

## Key Features

### 🔍 Link Coverage
- **Internal links**: Recursively crawls all pages within deportationdata.org
- **External links**: Checks external links found on pages without crawling into external sites
- **Anchor links**: Validates fragment/anchor links (#section) within pages

### 🚨 Issue Management  
- Creates detailed GitHub issues for broken links including:
  - Source page where the broken link was found
  - The broken URL and error details
  - Automatic labels: `bug`, `broken-link`, `automated`
- Prevents duplicates by checking for existing issues

## Schedule

The link checker runs automatically:
- **Weekly**: Every Monday at 9:00 AM UTC
- **Manual**: Can be triggered manually from the Actions tab

## Files

- `.github/workflows/check-links.yml`: GitHub Actions workflow
- `.github/scripts/check-links.sh`: Shell script that runs lychee and processes results
- `.github/scripts/create-issues.sh`: Shell script that creates GitHub issues using GitHub CLI
- `.github/scripts/exclude-patterns.txt`: Reference patterns for exclusions (handled in command line)

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
- **Check internal links**: Recursively crawls all pages within deportationdata.org domain
- **Check external links**: Validates external links found on pages without recursing into them
- **Check anchor links**: Validates fragment/anchor links within pages
- **Rate limiting**: Limited concurrency (4 concurrent requests) with 10-second timeouts
- **Smart exclusions**: Skips common file types (CSS, JS, images, etc.) and problematic social media patterns
- **Respectful crawling**: Follows redirects (up to 5) and respects server response times

## What gets checked

✅ **Included:**
- All internal pages and links within deportationdata.org
- External links found on internal pages (checked but not crawled)
- Anchor/fragment links (#section-name)
- HTTP and HTTPS links

❌ **Excluded:**
- Asset files (CSS, JS, images, PDFs, etc.)
- Mailto and telephone links
- Social media share URLs with tracking parameters
- Known problematic external domains (Facebook, Twitter, etc.)