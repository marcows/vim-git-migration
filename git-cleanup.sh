#!/bin/sh

# Vim Git repository cleanup
#
# Overview:
# - remove stale branches
# - remove empty commits
# - remove 6 commits from the 7.2 branch, only meant for 7.3
# - unify name and mail for author and commiter
# - replace tabs with spaces in commit messages
# - replace .hgignore with .gitignore

##############
#  - git-filter-branch und git-rebase machen tags kaputt
#    so klappt es: git filter-branch -f --tree-filter 'rm -f .hgignore' HEAD~5.. --tags
#    -> user müssen git fetch --tags machen, damit geänderter Tag aktualisiert wird -> ach komm, einfach neuer Klon mit --reference ../vim-git-test1 --dissociate
#    oder gleich nach löschen der anderen branches so: -- --all
#   --tag-name-filter cat
##############

set -e

# remove stale branches, have been closed in the HG repository
git branch -D vim vim72 vim73

# find empty commits
#for sha in $(git rev-list --min-parents=1 --max-parents=1 --all) ; do if [ $(git rev-parse ${sha}^{tree}) == $(git rev-parse ${sha}^1^{tree} ) ]; then echo $sha; fi; done > empty-commits.txt
# manually check if the empty commits can be removed without problems, not tags must point to them
#git show $(<empty-commits.txt) --oneline --decorate | vim -

# remove empty commits, most from handling of tags and branches
#git filter-branch --prune-empty -- master~10..
#git filter-branch --commit-filter 'git_commit_non_empty_tree "$@"' -- master~10..

# remove 6 commits from the 7.2 branch, only meant for 7.3
#   from "First step in the Vim 7.3 branch."
#   till "Undo changes that are meant for the Vim 7.3 branch."
#   -> v7.2.434~6..v7.2.434~1
#git filter-branch -f --commit-filter '
#    if test \( "$GIT_COMMIT" = `git rev-parse v7.2.434~6` \) \
#         -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~5` \) \
#         -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~4` \) \
#         -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~3` \) \
#         -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~2` \) \
#         -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~1` \)
#    then
#        skip_commit "$@"
#    else
#        git commit-tree "$@"
#        #git_commit_non_empty_tree "$@"
#    fi
#' -- master~15..

# unify name and mail for author and commiter,
# see "git shortlog --email -s"
#git filter-branch -f --env-filter '
#    GIT_COMMITTER_NAME="Bram Moolenaar"
#    GIT_COMMITTER_EMAIL="Bram@vim.org"
#    GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME"
#    GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL"
#    export GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
#    export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL
#' -- master~10..

# replace tabs with spaces in commit messages
#git filter-branch -f --msg-filter 'expand' -- adec411514410e59db7290b166e599c82ac118e8~10..

# replace .hgignore with .gitignore
#git filter-branch -f --tree-filter '
#    test -f .hgignore && sed -e "/syntax: glob/,+1d" .hgignore > .gitignore
#' -- master~15..
