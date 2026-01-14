# Local Preview Setup

This guide will help you set up and run your Jekyll site locally so you can preview changes before publishing.

## Prerequisites

### macOS (Your System)

macOS comes with Ruby pre-installed, but you may want to use a newer version.

Check your Ruby version:
```bash
ruby --version
```

You need Ruby 2.5.0 or higher. If you have an older version, consider installing a newer one via Homebrew:

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Ruby via Homebrew (optional, if system Ruby is too old)
brew install ruby

# Add to your PATH (add to ~/.zshrc or ~/.bash_profile)
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## One-Time Setup

### 1. Install Bundler

Bundler manages Ruby gem dependencies:

```bash
gem install bundler
```

If you get permission errors, try:
```bash
sudo gem install bundler
```

Or use the `--user-install` flag:
```bash
gem install --user-install bundler
```

### 2. Install Jekyll and Dependencies

Navigate to your website directory:
```bash
cd ~/Documents/Programming/Website
```

Install all required gems from the Gemfile:
```bash
bundle install
```

This will install Jekyll and all other dependencies listed in your `Gemfile`.

### Troubleshooting Installation Issues

**If you see errors about native extensions:**
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

**If bundle install fails:**
```bash
# Update Bundler
gem update bundler

# Try again
bundle install
```

**If you get permission errors:**
```bash
# Install gems to local directory
bundle install --path vendor/bundle
```

## Running the Local Server

Once setup is complete, you can start the Jekyll development server:

```bash
# Standard way
bundle exec jekyll serve

# With live reload (rebuilds on file changes)
bundle exec jekyll serve --livereload

# Use development config (if you have _config.dev.yml)
bundle exec jekyll serve --config _config.yml,_config.dev.yml

# Serve on a different port
bundle exec jekyll serve --port 4001

# Show future posts (posts dated in the future)
bundle exec jekyll serve --future

# Show draft posts (in _drafts folder)
bundle exec jekyll serve --drafts
```

### What This Does

The server will:
1. Build your Jekyll site into the `_site` directory
2. Start a local web server (usually at `http://localhost:4000`)
3. Watch for file changes and automatically rebuild
4. Keep running until you stop it (Ctrl+C)

### Viewing Your Site

Open your browser and go to:
```
http://localhost:4000
```

or

```
http://127.0.0.1:4000
```

### Making Changes

1. Leave the server running
2. Edit your markdown files, layouts, or config
3. Save the file
4. The site will automatically rebuild (watch the terminal output)
5. Refresh your browser to see changes

**Note:** Changes to `_config.yml` require a server restart.

## Stopping the Server

Press `Ctrl+C` in the terminal where Jekyll is running.

## Common Commands

Create a handy alias in your `~/.zshrc` or `~/.bash_profile`:

```bash
# Add these aliases
alias jserve="bundle exec jekyll serve"
alias jservef="bundle exec jekyll serve --future --drafts --livereload"

# Reload your shell
source ~/.zshrc
```

Now you can just type:
```bash
jserve        # Start the server
jservef       # Start with future posts, drafts, and live reload
```

## Helper Script

You can also create a simple script `serve.sh`:

```bash
#!/bin/bash
# Start Jekyll development server with common options

bundle exec jekyll serve --livereload --future --drafts --port 4000
```

Make it executable:
```bash
chmod +x serve.sh
```

Run it:
```bash
./serve.sh
```

## Workflow Example

Here's a typical workflow for creating and previewing a new post:

```bash
# 1. Navigate to your site directory
cd ~/Documents/Programming/Website

# 2. Create a new post (using our script)
./new-post.sh blog "My New Post Title"

# 3. Start the Jekyll server in a new terminal tab/window
bundle exec jekyll serve --livereload

# 4. Open http://localhost:4000 in your browser

# 5. Edit your post in your favorite editor
# The browser will auto-refresh when you save

# 6. When satisfied, commit and push
git add _posts/2026-01-14-my-new-post.md
git commit -m "Add new blog post"
git push origin main

# 7. Stop the server
# Press Ctrl+C in the terminal running Jekyll
```

## Directory Structure After Build

When Jekyll builds, it creates a `_site` directory:

```
_site/
├── index.html
├── posts/
│   └── 2026/01/my-post/
│       └── index.html
├── personal/
│   └── 2022-mlk-pub-crawl/
│       └── index.html
├── images/
└── ... (all your site files)
```

This is what gets published to GitHub Pages. You don't need to commit `_site` - it's in your `.gitignore`.

## Troubleshooting

### Port Already in Use

If you see "Address already in use":
```bash
# Find what's using port 4000
lsof -i :4000

# Kill it (replace PID with actual process ID)
kill -9 PID

# Or use a different port
bundle exec jekyll serve --port 4001
```

### Changes Not Showing Up

1. **Hard refresh** your browser: `Cmd + Shift + R`
2. **Clear browser cache**
3. **Check terminal** for build errors
4. **Restart Jekyll** if you changed `_config.yml`

### Build Errors

If you see errors like "could not locate Gemfile":
```bash
# Make sure you're in the right directory
cd ~/Documents/Programming/Website

# Check that Gemfile exists
ls -la Gemfile
```

If you see "Liquid Exception":
- Check your markdown files for syntax errors
- Look for unclosed tags like `{% if %}` without `{% endif %}`
- Check that image paths are correct

### Performance Issues

If the site is slow to rebuild:
```bash
# Exclude directories you don't need
bundle exec jekyll serve --skip-initial-build --incremental

# Or use the --profile flag to see what's slow
bundle exec jekyll build --profile
```

## Updating Dependencies

Periodically update your gems:

```bash
# Update all gems
bundle update

# Update just Jekyll
bundle update jekyll

# Check for outdated gems
bundle outdated
```

## Production Build

To build exactly as GitHub Pages will:

```bash
# Build without starting server
JEKYLL_ENV=production bundle exec jekyll build

# The site is now in _site/
# You can open _site/index.html in a browser
```

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Jekyll on GitHub Pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll)
- [Bundler Documentation](https://bundler.io/docs.html)

---

If you run into issues not covered here, check the Jekyll docs or feel free to add solutions to this guide!
