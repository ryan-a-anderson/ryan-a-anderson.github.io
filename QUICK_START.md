# Quick Start Guide

Welcome! This guide will help you quickly create and manage content on your website.

## Table of Contents

- [Creating a New Blog Post](#creating-a-new-blog-post)
- [Creating a New Personal Post](#creating-a-new-personal-post)
- [Adding Images](#adding-images)
- [Previewing Locally](#previewing-locally)
- [Publishing Changes](#publishing-changes)
- [Full Documentation](#full-documentation)

## Creating a New Blog Post

Use the convenience script:

```bash
cd ~/Documents/Programming/Website
./new-post.sh blog "Your Post Title"
```

This will:
1. Create a properly formatted file in `_posts/`
2. Add frontmatter with today's date
3. Prompt for excerpt and tags
4. Open the file in your editor

## Creating a New Personal Post

For personal content (like pub crawls):

```bash
./new-post.sh personal "Event Title"
```

This creates a file in `_personal/` that will appear in the Personal section of your site.

## Adding Images

### 1. Add image to the images directory

```bash
# For blog posts - create a subdirectory
mkdir -p images/posts/2026-01-my-post
cp ~/Downloads/my-image.jpg images/posts/2026-01-my-post/

# For personal posts
cp ~/Downloads/event-photo.jpg images/pub-crawl/
```

### 2. Reference in your markdown

```markdown
![Description of image](/images/posts/2026-01-my-post/my-image.jpg)

# With caption
![Description](/images/pub-crawl/event-photo.jpg)
*Caption goes here in italics*
```

**Pro tip:** Give images descriptive names like `model-comparison-plot.png` instead of `Untitled.png`

## Previewing Locally

Before publishing, preview your changes:

```bash
# First time only: install dependencies
bundle install

# Start local server (watches for changes)
bundle exec jekyll serve --livereload

# Open in browser: http://localhost:4000
```

Your site will auto-rebuild when you save files. Refresh your browser to see changes.

Press `Ctrl+C` to stop the server.

## Publishing Changes

Once you're happy with your changes:

```bash
# See what changed
git status

# Add your changes
git add .

# Commit with a descriptive message
git commit -m "Add blog post about X"

# Push to GitHub (triggers automatic deployment)
git push origin main
```

Your site will be live at https://ryan-a-anderson.github.io in a few minutes!

## Site Structure

```
ryan-a-anderson.github.io/
├── _posts/          # Academic blog posts
├── _personal/       # Personal posts (pub crawls, etc.)
├── images/          # All images
│   ├── posts/       # Blog post images
│   └── pub-crawl/   # Personal event images
├── BLOG_GUIDE.md    # Comprehensive markdown guide
├── LOCAL_PREVIEW.md # Detailed setup instructions
└── new-post.sh      # Post creation script
```

## Common Tasks

### Write math equations

```markdown
Inline: $E = mc^2$

Display:
$$
\int_{0}^{\infty} e^{-x} dx = 1
$$
```

### Add code blocks

````markdown
```python
def hello():
    print("Hello, world!")
```
````

### Add links

```markdown
[Link text](https://example.com)
[Internal link](/about/)
```

### Format text

```markdown
**bold**
*italic*
~~strikethrough~~
```

## Full Documentation

- **[BLOG_GUIDE.md](BLOG_GUIDE.md)** - Complete markdown formatting guide, LaTeX, images, etc.
- **[LOCAL_PREVIEW.md](LOCAL_PREVIEW.md)** - Detailed Jekyll setup and troubleshooting
- **[images/README.md](images/README.md)** - Image organization and optimization guide

## Need Help?

1. Check the guides above
2. Look at existing posts for examples:
   - Blog: `_posts/2022-12-31-bbhof-report.md`
   - Personal: `_personal/2022-mlk-pub-crawl.md`
3. Jekyll docs: https://jekyllrb.com/docs/

---

Happy writing!
