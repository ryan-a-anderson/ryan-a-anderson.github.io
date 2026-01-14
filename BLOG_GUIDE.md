# Blog Editing Guide

This guide will help you create and edit blog posts and personal content on your Jekyll-based website.

## Table of Contents

1. [Creating New Posts](#creating-new-posts)
2. [Post Frontmatter](#post-frontmatter)
3. [Markdown Formatting](#markdown-formatting)
4. [Adding Images](#adding-images)
5. [Math Equations (LaTeX)](#math-equations-latex)
6. [Code Blocks](#code-blocks)
7. [Links and References](#links-and-references)
8. [Local Preview](#local-preview)

## Creating New Posts

### Using the Script (Recommended)

The easiest way to create a new post is using the `new-post.sh` script:

```bash
# Create a new blog post
./new-post.sh blog "Your Post Title Here"

# Create a new personal post
./new-post.sh personal "Your Personal Post Title"

# Interactive mode (will prompt for title)
./new-post.sh blog
```

The script will:
- Generate a properly formatted filename
- Create frontmatter with the correct date
- Prompt for optional excerpt and tags
- Open the file in your editor

### Manual Creation

#### Blog Posts
Create files in `_posts/` with the naming format: `YYYY-MM-DD-title-slug.md`

Example: `_posts/2026-01-14-my-new-post.md`

#### Personal Posts
Create files in `_personal/` with any meaningful name: `descriptive-name.md`

Example: `_personal/2026-pub-crawl.md`

## Post Frontmatter

Every post starts with YAML frontmatter between `---` markers:

```yaml
---
title: "Your Post Title"
date: 2026-01-14
permalink: /posts/2026/01/my-post/
excerpt: "A brief description that appears in post listings"
tags:
  - machine learning
  - statistics
  - python
---
```

### Frontmatter Fields

- `title`: The post title (required)
- `date`: Publication date in YYYY-MM-DD format (required)
- `permalink`: Custom URL for the post (optional but recommended)
- `excerpt`: Short description for listings (optional)
- `tags`: List of tags for categorization (optional)

## Markdown Formatting

### Headers

```markdown
# H1 Header
## H2 Header
### H3 Header
#### H4 Header
```

### Text Formatting

```markdown
*italic text* or _italic text_
**bold text** or __bold text__
***bold and italic*** or ___bold and italic___
~~strikethrough~~
```

### Lists

Unordered lists:
```markdown
- Item 1
- Item 2
  - Nested item 2.1
  - Nested item 2.2
- Item 3
```

Ordered lists:
```markdown
1. First item
2. Second item
3. Third item
```

### Quotes

```markdown
> This is a blockquote.
> It can span multiple lines.
>
> And multiple paragraphs.
```

### Horizontal Rules

```markdown
---
or
***
or
___
```

## Adding Images

### Image Directory Structure

Store images in organized directories:
- `/images/posts/` - For blog post images
- `/images/pub-crawl/` - For pub crawl images
- `/images/` - For general site images

### Recommended Organization

```
images/
├── pub-crawl/
│   ├── 2022-image1.png
│   └── 2023-image2.jpg
├── posts/
│   ├── 2026-01-modeling/
│   │   ├── figure1.png
│   │   └── figure2.png
│   └── 2026-02-statistics/
│       └── plot.png
└── profile.jpg
```

### Markdown Syntax for Images

```markdown
![Alt text description](/images/posts/2026-01-modeling/figure1.png)

# With caption
![Alt text](/images/posts/figure.png)
*Caption text appears below as italics*

# With link
[![Alt text](/images/photo.jpg)](/path/to/full-size.jpg)
```

### Image Best Practices

1. **File names**: Use descriptive, lowercase names with hyphens
   - Good: `pheidippides-marathon.png`
   - Bad: `Untitled 1.png`

2. **File formats**:
   - Photos: `.jpg` or `.jpeg`
   - Graphics/diagrams: `.png`
   - Avoid: `.heic` (not web-compatible)

3. **File size**: Compress images before uploading
   - Use tools like ImageOptim, TinyPNG, or `convert` command

4. **Alt text**: Always provide descriptive alt text for accessibility

## Math Equations (LaTeX)

Your site uses Kramdown with MathJax support for rendering LaTeX math.

### Inline Math

Use single dollar signs:
```markdown
The equation $E = mc^2$ is Einstein's famous formula.
```

### Display Math (Block)

Use double dollar signs:
```markdown
$$
\text{max_pct}_j = \max_{i \in Y_j}\left(\frac{V_{i,j}}{B_{i}}\right)
$$
```

### Common Math Examples

```latex
# Fractions
$$\frac{a}{b}$$

# Summation
$$\sum_{i=1}^{n} x_i$$

# Integrals
$$\int_{0}^{\infty} e^{-x} dx$$

# Matrices
$$\begin{bmatrix} a & b \\ c & d \end{bmatrix}$$

# Aligned equations
$$
\begin{align}
f(x) &= x^2 + 2x + 1 \\
     &= (x+1)^2
\end{align}
$$
```

## Code Blocks

### Inline Code

Use single backticks:
```markdown
The `print()` function outputs text.
```

### Code Blocks with Syntax Highlighting

Use triple backticks with language specification:

````markdown
```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
```

```r
# R example
data <- read.csv("file.csv")
model <- lm(y ~ x, data=data)
summary(model)
```

```bash
# Bash example
git add .
git commit -m "Update post"
git push origin main
```
````

Supported languages: python, r, bash, javascript, java, cpp, ruby, sql, yaml, json, and many more.

## Links and References

### Basic Links

```markdown
[Link text](https://example.com)
[Link with title](https://example.com "Hover text")
```

### Internal Links

```markdown
[About page](/about/)
[Another post](/posts/2025/12/post-title/)
```

### Reference-Style Links

```markdown
[Link text][reference]

[reference]: https://example.com "Optional title"
```

### Footnotes

```markdown
Here's a sentence with a footnote[^1].

[^1]: This is the footnote content.
```

## Local Preview

### First-Time Setup

1. Install Ruby (macOS usually has it pre-installed):
```bash
ruby --version
```

2. Install Bundler:
```bash
gem install bundler
```

3. Install Jekyll and dependencies:
```bash
cd ~/Documents/Programming/Website
bundle install
```

### Running the Local Server

```bash
# Start the Jekyll server
bundle exec jekyll serve

# Or use the dev config (if you have one)
bundle exec jekyll serve --config _config.yml,_config.dev.yml

# Server will run at http://localhost:4000
# Press Ctrl+C to stop
```

### Live Reload

The site will automatically rebuild when you save changes. Just refresh your browser to see updates.

### Troubleshooting

**Port already in use:**
```bash
bundle exec jekyll serve --port 4001
```

**Gemfile.lock issues:**
```bash
bundle update
```

**Config changes not showing:**
Restart the Jekyll server - config changes require a restart.

## Publishing Changes

### Using Git

```bash
# Check what files changed
git status

# Add your changes
git add _posts/2026-01-14-my-new-post.md
git add images/posts/my-image.png

# Or add all changes
git add .

# Commit with a message
git commit -m "Add new blog post about X"

# Push to GitHub (triggers GitHub Pages rebuild)
git push origin main
```

Your site will automatically rebuild and deploy via GitHub Pages within a few minutes.

## Tips and Best Practices

1. **Preview locally first**: Always preview posts locally before publishing
2. **Use descriptive filenames**: Makes finding and organizing content easier
3. **Optimize images**: Large images slow down your site
4. **Write good excerpts**: They appear in post listings and search results
5. **Tag consistently**: Use existing tags when possible for better organization
6. **Check math rendering**: LaTeX can be tricky - preview equations locally
7. **Break up long posts**: Use headers to create clear sections
8. **Link to related posts**: Build connections between your content

## Quick Reference Card

```markdown
# Common Formatting

**Bold**              **text** or __text__
*Italic*              *text* or _text_
`Code`                `code`
[Link](url)           [text](https://example.com)
![Image](url)         ![alt](/images/pic.jpg)
$Math$                $E=mc^2$

# Lists
- Bullet             - item
1. Numbered          1. item

# Code block
```python
code here
```

# Math block
$$
equation here
$$
```

## Additional Resources

- [Kramdown Syntax](https://kramdown.gettalong.org/syntax.html)
- [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/)
- [MathJax Documentation](https://www.mathjax.org/)
- [Jekyll Documentation](https://jekyllrb.com/docs/)

---

Happy blogging! If you have questions or want to add something to this guide, just update this file.
