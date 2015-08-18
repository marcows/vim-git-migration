#!/bin/sh

# abort if work repositories don't exist
test -d vim-hg-base-git || { echo abort: vim-hg-base-git does not exists && exit 1; }

# abort if work repositories still exist
test -d vim-hg-base-git-copy && { echo abort: vim-hg-base-git-copy exists && exit 1; }

# copy the originally converted Git repository
cp -a vim-hg-base-git vim-hg-base-git-copy

# run the cleanup script
cd vim-hg-base-git-copy
sh ../cleanup/git-cleanup.sh

# verify the result manually
cd ../vim-hg-base-git-copy
echo "Verify \"vim-hg-base-git-copy\""
