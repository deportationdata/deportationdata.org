#!/usr/bin/env python3
"""
Simple link checker for deportationdata.org
Crawls the website recursively and creates GitHub issues for broken links.
"""

import os
import sys
import json
import time
import requests
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
from collections import deque
import re

# Configuration
BASE_URL = "https://deportationdata.org"
DOMAIN = "deportationdata.org"
GITHUB_API_URL = "https://api.github.com"
USER_AGENT = "DeportationData-LinkChecker/1.0"

class LinkChecker:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': USER_AGENT})
        self.visited_pages = set()
        self.checked_links = set()
        self.broken_links = []
        self.github_token = os.environ.get('GITHUB_TOKEN')
        self.github_repo = os.environ.get('GITHUB_REPOSITORY')
        
        if not self.github_token or not self.github_repo:
            print("ERROR: GITHUB_TOKEN and GITHUB_REPOSITORY environment variables must be set")
            sys.exit(1)
    
    def is_internal_link(self, url):
        """Check if a URL is internal to our domain"""
        parsed = urlparse(url)
        return parsed.netloc == DOMAIN or parsed.netloc == ""
    
    def normalize_url(self, url, base_url):
        """Normalize URL and make it absolute"""
        if not url or url.startswith('#') or url.startswith('mailto:') or url.startswith('tel:'):
            return None
        
        # Handle relative URLs
        absolute_url = urljoin(base_url, url)
        
        # Only process internal URLs
        if not self.is_internal_link(absolute_url):
            return None
            
        # Remove fragments
        parsed = urlparse(absolute_url)
        normalized = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
        
        # Remove trailing slash for consistency, except for root
        if normalized.endswith('/') and len(parsed.path) > 1:
            normalized = normalized.rstrip('/')
            
        return normalized
    
    def check_url_status(self, url):
        """Check the HTTP status of a URL"""
        try:
            response = self.session.head(url, timeout=10, allow_redirects=True)
            return response.status_code, response.reason
        except requests.exceptions.RequestException as e:
            try:
                # Try GET request if HEAD fails
                response = self.session.get(url, timeout=10, allow_redirects=True)
                return response.status_code, response.reason
            except requests.exceptions.RequestException as get_e:
                return None, str(get_e)
    
    def extract_links(self, html, base_url):
        """Extract all links from HTML content"""
        soup = BeautifulSoup(html, 'html.parser')
        links = []
        
        # Find all links
        for tag in soup.find_all(['a', 'link']):
            href = tag.get('href')
            if href:
                normalized = self.normalize_url(href, base_url)
                if normalized:
                    links.append(normalized)
        
        # Find links in images, scripts, etc.
        for tag in soup.find_all(['img', 'script']):
            src = tag.get('src')
            if src:
                normalized = self.normalize_url(src, base_url)
                if normalized:
                    links.append(normalized)
        
        return list(set(links))  # Remove duplicates
    
    def crawl_page(self, url):
        """Crawl a single page and extract links"""
        if url in self.visited_pages:
            return []
        
        print(f"Crawling: {url}")
        self.visited_pages.add(url)
        
        try:
            response = self.session.get(url, timeout=15)
            if response.status_code != 200:
                print(f"  WARNING: {url} returned {response.status_code}")
                return []
            
            # Only process HTML content
            content_type = response.headers.get('content-type', '').lower()
            if 'text/html' not in content_type:
                return []
            
            links = self.extract_links(response.text, url)
            print(f"  Found {len(links)} links")
            return links
            
        except requests.exceptions.RequestException as e:
            print(f"  ERROR crawling {url}: {e}")
            return []
    
    def crawl_website(self):
        """Crawl the entire website starting from the root"""
        print(f"Starting to crawl {BASE_URL}")
        
        to_visit = deque([BASE_URL])
        all_links = set()
        max_pages = 50  # Limit to prevent excessive crawling
        
        while to_visit and len(self.visited_pages) < max_pages:
            current_url = to_visit.popleft()
            
            if current_url in self.visited_pages:
                continue
            
            # Rate limiting
            time.sleep(0.5)
            
            links = self.crawl_page(current_url)
            
            for link in links:
                all_links.add((link, current_url))  # (link, source_page)
                
                # Add pages to visit queue (only HTML pages likely to be pages)
                if (self.is_internal_link(link) and 
                    link not in self.visited_pages and
                    len(self.visited_pages) < max_pages):
                    # Only queue URLs that look like pages (not images, etc.)
                    if not re.search(r'\.(css|js|png|jpg|jpeg|gif|pdf|zip|xml|ico|svg|woff|woff2|ttf|eot)$', link.lower()):
                        to_visit.append(link)
        
        print(f"Crawling complete. Found {len(all_links)} total links from {len(self.visited_pages)} pages")
        return all_links
    
    def check_all_links(self, links):
        """Check all discovered links for broken ones"""
        print("Checking all links for broken ones...")
        
        for link, source_page in links:
            if link in self.checked_links:
                continue
                
            self.checked_links.add(link)
            print(f"Checking: {link}")
            
            status_code, reason = self.check_url_status(link)
            
            # Consider 4xx and 5xx as broken, but allow redirects
            if status_code is None or status_code >= 400:
                print(f"  BROKEN: {status_code} - {reason}")
                self.broken_links.append({
                    'url': link,
                    'source_page': source_page,
                    'status_code': status_code,
                    'reason': reason
                })
            else:
                print(f"  OK: {status_code}")
            
            # Rate limiting
            time.sleep(0.2)
    
    def check_existing_issues(self, broken_url):
        """Check if an issue already exists for this broken link"""
        headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        # Search for existing issues with the broken URL
        search_query = f"repo:{self.github_repo} is:issue is:open \"{broken_url}\" label:broken-link"
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
        
        body = f"""A broken link was detected on the website.

**Broken URL:** {broken_link['url']}
**Found on page:** {broken_link['source_page']}
**HTTP Status:** {broken_link['status_code'] or 'Connection Error'}
**Error:** {broken_link['reason']}

**Details:**
This issue was automatically created by the link checker workflow.

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
    
    def run(self):
        """Main method to run the link checker"""
        print("=== DeportationData.org Link Checker ===")
        
        # Step 1: Crawl the website
        all_links = self.crawl_website()
        
        # Step 2: Check all links
        self.check_all_links(all_links)
        
        # Step 3: Report results
        print(f"\n=== RESULTS ===")
        print(f"Pages crawled: {len(self.visited_pages)}")
        print(f"Links checked: {len(self.checked_links)}")
        print(f"Broken links found: {len(self.broken_links)}")
        
        if self.broken_links:
            print("\nBroken links:")
            for broken in self.broken_links:
                print(f"  - {broken['url']} (from {broken['source_page']}) - {broken['status_code']}: {broken['reason']}")
            
            # Step 4: Create GitHub issues
            print(f"\nCreating GitHub issues for {len(self.broken_links)} broken links...")
            created_count = 0
            for broken in self.broken_links:
                if self.create_github_issue(broken):
                    created_count += 1
                time.sleep(1)  # Rate limiting for GitHub API
            
            print(f"Created {created_count} GitHub issues")
        else:
            print("\n✅ No broken links found!")

if __name__ == "__main__":
    checker = LinkChecker()
    checker.run()