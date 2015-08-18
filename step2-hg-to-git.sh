#!/bin/sh

# abort if work repositories don't exist
test -d vim-hg-base || { echo abort: vim-hg-base does not exists && exit 1; }

# abort if work repositories still exist
test -d vim-hg-base-git && { echo abort: vim-hg-base-git exists && exit 1; }

# create an empty git repository
mkdir vim-hg-base-git
cd vim-hg-base-git
git init

# do the HG to Git conversion
PYTHON=python2 ../../fast-export/hg-fast-export.sh -r ../vim-hg-base

# optimize the packfiles
git repack -a -d -f
git gc

# get a clean index
git checkout

# verify the result manually
cd ../vim-hg-base-git
echo "Verify \"vim-hg-base-git\""
