#!/bin/sh

# abort if work repositories don't exist
test -d vim-hg || { echo abort: vim-hg does not exists && exit 1; }

# abort if work repositories still exist
test -d vim-hg-base && { echo abort: vim-hg-base exists && exit 1; }
test -d vim-hg-basecloned && { echo abort: vim-hg-basecloned exists && exit 1; }

# copy the original HG repository
cp -a vim-hg vim-hg-base

# clone the copy
hg clone vim-hg-base vim-hg-basecloned

# run the cleanup script
cd vim-hg-basecloned
sh ../cleanup/hg-cleanup.sh

# push back from the cloned copy to the initial copy to verify that no
# history has been rewritten, elsewise this command would fail
hg push

# verify the result manually with "hgk" or "hg log", compare with the
# original repository
cd ../vim-hg-base
echo "Verify \"vim-hg-base\" with \"hgk\" or \"hg log --style compact --graph\""
