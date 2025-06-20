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