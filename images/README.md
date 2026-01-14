# Images Directory Organization

This directory contains all images used across the website.

## Directory Structure

```
images/
├── posts/           # Blog post images
│   └── YYYY-MM-title/  # Organize by post
├── pub-crawl/       # Pub crawl event images
├── profile images   # Profile photos, bio images
└── other categories as needed
```

## Guidelines

### Naming Conventions

- **Be descriptive**: `pheidippides-marathon.png` not `image1.png`
- **Use lowercase**: `my-image.jpg` not `My-Image.jpg`
- **Use hyphens**: `my-image.png` not `my_image.png` or `myimage.png`
- **No spaces**: Never use spaces in filenames

### File Organization

**For blog posts:**
Create a subdirectory for each post with multiple images:
```
images/posts/2026-01-modeling-predictions/
├── figure-1-model-comparison.png
├── figure-2-results.png
└── dataset-overview.jpg
```

For posts with just one or two images, you can place them directly in `images/posts/`:
```
images/posts/
├── 2026-01-quick-note-diagram.png
└── 2026-02-simple-plot.jpg
```

**For personal content:**
```
images/pub-crawl/
├── 2022-pheidippides.png
├── 2022-mike-rest.jpeg
├── 2023-west-general-wolfe.png
└── 2026-desert-storm.png
```

### File Formats

- **Photos**: Use `.jpg` or `.jpeg`
  - Best for photographs and images with many colors
  - Smaller file sizes with acceptable quality loss

- **Graphics/Diagrams**: Use `.png`
  - Best for diagrams, screenshots, text
  - Lossless compression, crisp edges

- **Avoid**:
  - `.heic` - Not universally supported in browsers
  - `.bmp` - Unnecessarily large file sizes
  - `.gif` - Only if you need animation

### Image Optimization

Always optimize images before adding them to the repository:

**Using ImageMagick (command line):**
```bash
# Resize to max width of 1200px
convert input.jpg -resize 1200x output.jpg

# Compress JPEG
convert input.jpg -quality 85 output.jpg

# Convert HEIC to JPEG
convert input.heic output.jpg
```

**Using macOS Preview:**
1. Open image in Preview
2. Tools → Adjust Size
3. Set max dimension to 1200-1600px
4. Export with quality ~85%

**Online tools:**
- [TinyPNG](https://tinypng.com/) - Great for PNG compression
- [Squoosh](https://squoosh.app/) - Google's image optimizer

### Adding Images to Posts

In your markdown files, reference images using absolute paths:

```markdown
![Descriptive alt text](/images/posts/2026-01-post/figure-1.png)
```

Always include:
1. **Descriptive alt text** for accessibility
2. **Caption** if needed (use italics below the image)

Example with caption:
```markdown
![Merson's painting showing Pheidippides](/images/pub-crawl/pheidippides.png)

*Merson's "Pheidippides Giving Word of Victory After the Battle of Marathon," 1869*
```

## Quick Add Script

You can create a helper script `add-image.sh`:

```bash
#!/bin/bash
# Usage: ./add-image.sh /path/to/image.jpg posts/my-post/

SOURCE=$1
DEST_DIR="images/$2"

mkdir -p "$DEST_DIR"

# Get filename
FILENAME=$(basename "$SOURCE")

# Copy and optimize
cp "$SOURCE" "$DEST_DIR/$FILENAME"

echo "Image added to $DEST_DIR/$FILENAME"
echo "Markdown: ![Alt text](/$DEST_DIR/$FILENAME)"
```

## Image Size Guidelines

- **Max width**: 1600px (for high-DPI displays)
- **Typical width**: 800-1200px
- **Thumbnails**: 300-400px
- **File size**: Aim for <500KB per image, <200KB ideal

## Accessibility

Always include descriptive alt text:

- **Good**: `![Graph showing model accuracy over training epochs](/images/posts/accuracy-plot.png)`
- **Bad**: `![](/images/posts/graph.png)`

Alt text should:
- Describe the content and function of the image
- Be concise (1-2 sentences)
- Omit "image of" or "picture of" (screen readers already announce it's an image)

---

For more information, see the main [BLOG_GUIDE.md](../BLOG_GUIDE.md).
