#!/usr/bin/env bash

# Step 1: verify that `mise` is available on the system
# Step 1a: if it's not, point the user at the installation instruction matching their circumstances:
  - https://mise.jdx.dev/installing-mise.html#homebrew if Homebrew is available on the system
  - https://mise.jdx.dev/installing-mise.html#apt if APT is available on the system
  - https://mise.jdx.dev/installing-mise.html#https-mise-run if the none of the above matches

# Step 2: place `mise-tasks/etfs.sh` from this repository into the global mise task folder of the current unix user
# Step 2a: Use `$MISE_CONFIG_DIR` if set and non-empty, or fall back to `${XDG_CONFIG_HOME:-$HOME/.config}/mise` if not, and add `/tasks/` (create if needed), as the target location for file `etfs.sh`

# Step 3: Explain that from now on, the user can simply run `mise run etfs` to run the ETFS cli
