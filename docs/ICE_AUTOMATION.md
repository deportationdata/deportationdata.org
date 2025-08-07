# ICE Detention Data Automation

This repository includes automated scraping and processing of ICE detention management data from the official ICE website.

## Overview

The automation workflow:

1. **Daily Check**: Runs daily at 10 AM UTC to check for updates on https://www.ice.gov/detain/detention-management
2. **Data Processing**: If the "Last Updated" date is today, downloads the latest spreadsheet
3. **Box Upload**: Uploads the file to Box under `deportationdata/ICE/detention_management` using the exact downloaded filename
4. **Verification**: Verifies the Box file can be accessed
5. **Website Update**: Updates both English and Spanish reports pages, moving the previous latest file to "Past reports" and promoting the new file
6. **Pull Request**: Creates a PR with all changes and requests review

## Setup Requirements

### GitHub Secrets

The following secrets must be configured in the repository settings:

- `BOX_CLIENT_ID`: Box application client ID
- `BOX_CLIENT_SECRET`: Box application client secret

### Box API Setup

1. Create a Box application at https://developer.box.com/
2. Configure the application with appropriate permissions for file upload and folder management
3. Generate client credentials
4. Ensure the Box application has access to the `deportationdata/ICE/detention_management` folder structure

## Files

### Scripts

- `scripts/ice_detention_scraper.R`: Main scraping script that checks ICE website, downloads files, and uploads to Box
- `scripts/update_reports.R`: Updates the reports.qmd files (English and Spanish) with new data entries

### Workflow

- `.github/workflows/ice-detention-automation.yml`: GitHub Action that orchestrates the entire process

## Manual Execution

The workflow can be triggered manually using the "workflow_dispatch" trigger in the GitHub Actions interface.

## Error Handling

The scripts include comprehensive error handling for:
- Network issues when accessing the ICE website
- File download failures
- Box API authentication and upload issues
- Report file update failures

If any step fails, the workflow will stop and report the error without creating a pull request.

## Review Process

When new data is found, the automation:
1. Creates a new branch named `automated-ice-update-{date}`
2. Commits all changes with a descriptive message
3. Creates a pull request with detailed information about what was updated
4. Requests review from designated reviewers
5. Includes verification checklist for manual review

The PR will not be automatically merged and requires manual review and approval.

## Customization

### Schedule

To change the schedule, modify the cron expression in `.github/workflows/ice-detention-automation.yml`:

```yaml
schedule:
  - cron: '0 10 * * *'  # 10 AM UTC daily
```

### Reviewers

Update the reviewer username in the workflow file:

```yaml
reviewers: |
  [REVIEWER_USERNAME]  # Replace with actual reviewer
```

And in the PR body:

```
/cc @[REVIEWER_USERNAME]  <!-- Replace with actual reviewer -->
```

## Monitoring

Check the GitHub Actions tab to monitor workflow runs and troubleshoot any issues. The workflow logs provide detailed information about each step of the process.