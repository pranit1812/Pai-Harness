PIPELINES = {
  "landing_page": {
    "goal": "Build a small landing page for 'Glitch Factory' as index.html (valid HTML5, doctype, title, a call-to-action link with id=\"cta\"), plus test_page.py that asserts the title and cta exist.",
    "checks": ["file_exists", "html_valid", "tests_pass"],
  }
}
