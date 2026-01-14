#!/bin/bash

# Script to create a new blog post or personal post
# Usage: ./new-post.sh [type] [title]
# Type: 'blog' or 'personal' (default: blog)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Determine post type
TYPE=${1:-blog}
shift 2>/dev/null || true

# Get title
if [ -z "$1" ]; then
    echo -e "${YELLOW}Enter post title:${NC}"
    read -r TITLE
else
    TITLE="$*"
fi

# Validate inputs
if [ -z "$TITLE" ]; then
    echo "Error: Title cannot be empty"
    exit 1
fi

# Generate filename-safe title (lowercase, replace spaces with hyphens)
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Get current date
DATE=$(date +%Y-%m-%d)

# Determine directory and filename based on type
if [ "$TYPE" = "personal" ]; then
    DIR="_personal"
    FILENAME="${DIR}/${SLUG}.md"
    PERMALINK="/personal/${SLUG}/"
else
    DIR="_posts"
    FILENAME="${DIR}/${DATE}-${SLUG}.md"
    PERMALINK="/posts/$(date +%Y)/$(date +%m)/${SLUG}/"
fi

# Check if file already exists
if [ -f "$FILENAME" ]; then
    echo -e "${YELLOW}Warning: File $FILENAME already exists!${NC}"
    echo "Overwrite? (y/n)"
    read -r RESPONSE
    if [ "$RESPONSE" != "y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

# Get excerpt
echo -e "${BLUE}Enter a short excerpt (optional, press enter to skip):${NC}"
read -r EXCERPT

# Get tags
echo -e "${BLUE}Enter tags separated by commas (optional, press enter to skip):${NC}"
read -r TAGS_INPUT

# Create frontmatter
cat > "$FILENAME" << EOF
---
title: "$TITLE"
date: $DATE
permalink: $PERMALINK
EOF

# Add excerpt if provided
if [ -n "$EXCERPT" ]; then
    echo "excerpt: \"$EXCERPT\"" >> "$FILENAME"
fi

# Add tags if provided
if [ -n "$TAGS_INPUT" ]; then
    echo "tags:" >> "$FILENAME"
    IFS=',' read -ra TAGS <<< "$TAGS_INPUT"
    for tag in "${TAGS[@]}"; do
        # Trim whitespace
        tag=$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "  - $tag" >> "$FILENAME"
    done
fi

# Close frontmatter
echo "---" >> "$FILENAME"
echo "" >> "$FILENAME"

# Add some template content
if [ "$TYPE" = "blog" ]; then
    cat >> "$FILENAME" << 'EOF'
# Introduction

Write your introduction here.

# Main Content

Write your main content here.

## Subsection

More content here.

# Conclusion

Wrap up your thoughts here.
EOF
else
    cat >> "$FILENAME" << 'EOF'
# Overview

Write your content here.
EOF
fi

echo -e "${GREEN}✓ Created new $TYPE post: $FILENAME${NC}"
echo -e "${BLUE}Opening in default editor...${NC}"

# Open in default editor (uses EDITOR env var, falls back to vim)
${EDITOR:-vim} "$FILENAME"
