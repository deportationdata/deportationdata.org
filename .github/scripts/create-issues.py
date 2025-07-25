#!/usr/bin/env python3
"""
GitHub issue creator for broken links found by muffet.
Processes muffet JSON output and creates GitHub issues for broken links.
"""

import os
import sys
import json
import time
import requests
from urllib.parse import urlparse

# Configuration
GITHUB_API_URL = "https://api.github.com"

class IssueCreator:
    def __init__(self):
        self.github_token = os.environ.get('GITHUB_TOKEN')
        self.github_repo = os.environ.get('GITHUB_REPOSITORY')
        
        if not self.github_token or not self.github_repo:
            print("ERROR: GITHUB_TOKEN and GITHUB_REPOSITORY environment variables must be set")
            sys.exit(1)
    
    def parse_muffet_output(self, results_file):
        """Parse muffet JSON output to extract broken links"""
        broken_links = []
        
        try:
            with open(results_file, 'r') as f:
                # Muffet outputs one JSON object per line
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    
                    try:
                        result = json.loads(line)
                        # Muffet reports errors as JSON objects with specific structure
                        if 'error' in result and result.get('url'):
                            broken_links.append({
                                'url': result['url'],
                                'source_page': result.get('source', 'Unknown'),
                                'error': result['error']
                            })
                    except json.JSONDecodeError:
                        # Skip lines that aren't valid JSON
                        continue
                        
        except FileNotFoundError:
            print(f"Results file {results_file} not found")
            return []
        except Exception as e:
            print(f"Error parsing results file: {e}")
            return []
        
        return broken_links
    
    def check_existing_issues(self, broken_url):
        """Check if an issue already exists for this broken link"""
        headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        # Search for existing issues with the broken URL
        search_query = f'repo:{self.github_repo} is:issue is:open "{broken_url}" label:broken-link'
        url = f"{GITHUB_API_URL}/search/issues"
        
        try:
            response = requests.get(url, headers=headers, params={'q': search_query})
            if response.status_code == 200:
                data = response.json()
                return data['total_count'] > 0
            else:
                print(f"Warning: Could not check existing issues: {response.status_code}")
                return False
        except requests.exceptions.RequestException as e:
            print(f"Warning: Error checking existing issues: {e}")
            return False
    
    def create_github_issue(self, broken_link):
        """Create a GitHub issue for a broken link"""
        # Check if issue already exists
        if self.check_existing_issues(broken_link['url']):
            print(f"Issue already exists for {broken_link['url']}, skipping...")
            return True
        
        title = f"Broken link found: {broken_link['url']}"
        
        body = f"""A broken link was detected on the website by the automated link checker.

**Broken URL:** {broken_link['url']}
**Found on page:** {broken_link['source_page']}
**Error:** {broken_link['error']}

**Details:**
This issue was automatically created by the link checker workflow using [muffet](https://github.com/raviqqe/muffet).

Please check the link and either fix it or remove it from the source page.

---
*This issue was created automatically by the [Check Website Links workflow](https://github.com/{self.github_repo}/actions/workflows/check-links.yml)*
"""
        
        headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
        
        data = {
            'title': title,
            'body': body,
            'labels': ['bug', 'broken-link', 'automated']
        }
        
        url = f"{GITHUB_API_URL}/repos/{self.github_repo}/issues"
        
        try:
            response = requests.post(url, headers=headers, json=data)
            if response.status_code == 201:
                issue_url = response.json()['html_url']
                print(f"Created issue: {issue_url}")
                return True
            else:
                print(f"Failed to create issue: {response.status_code} - {response.text}")
                return False
        except requests.exceptions.RequestException as e:
            print(f"Error creating issue: {e}")
            return False
    
    def process_results(self, results_file):
        """Process muffet results and create GitHub issues"""
        broken_links = self.parse_muffet_output(results_file)
        
        if not broken_links:
            print("✅ No broken links found!")
            return
        
        print(f"Found {len(broken_links)} broken links")
        
        # Create GitHub issues
        created_count = 0
        for broken in broken_links:
            print(f"Processing: {broken['url']}")
            if self.create_github_issue(broken):
                created_count += 1
            time.sleep(1)  # Rate limiting for GitHub API
        
        print(f"Created {created_count} GitHub issues for broken links")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python create-issues.py <muffet_results_file>")
        sys.exit(1)
    
    results_file = sys.argv[1]
    creator = IssueCreator()
    creator.process_results(results_file)