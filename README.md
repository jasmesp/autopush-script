# AutoPush

## Description

This script watches a directory and commits changes to a Git repository on every change, then pushes every 5 minutes. It's a simple way to keep your repository up to date without having to manually commit and push.

## Install

```bash
sudo apt install fswatch 
# or pacman -S fswatch, etc.
chmod +x autopush.sh
./autopush.sh
```

## Usage

```bash
./autopush.sh
```

## NOTE:
***THIS COMMITS AND PUSHES EVERYTHING!***


Before you run the script in a public repository, make sure your project has a robust `.gitignore` to avoid accidentally committing editor swap files, build artifacts, or secrets. At a minimum, include:

```gitignore
.pending_push        # Auto-push script flag (never commit this)
.env                 # Environment variables / secrets
*.DS_Store           # macOS Finder files
*.swp *.tmp          # Editor swap / temp files
```
