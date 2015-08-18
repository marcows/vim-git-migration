#!/bin/sh

# Vim Git repository cleanup
#
# Overview:
# - remove stale branches
# - unify name and mail for author and commiter
# - replace .hgignore with .gitignore
# - replace tabs with spaces in commit messages
# - remove empty commits
# - remove 6 commits from the 7.2 branch, only meant for 7.3

set -e

# remove stale branches, have been closed in the HG repository
git branch -D vim vim72 vim73

# find empty commits
#for sha in $(git rev-list --min-parents=1 --max-parents=1 master) ; do if [ $(git rev-parse ${sha}^{tree}) == $(git rev-parse ${sha}^1^{tree} ) ]; then echo $sha; fi; done > empty-commits.txt
# manually check if the empty commits can be removed without problems, not tags must point to them
#git show $(<empty-commits.txt) --oneline --decorate | vim -

# rewrite history
git filter-branch \
    --env-filter '
        # unify name and mail for author and commiter,
        # see "git shortlog --email --summary"
        GIT_COMMITTER_NAME="Bram Moolenaar"
        GIT_COMMITTER_EMAIL="Bram@vim.org"
        GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME"
        GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL"
        export GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
        export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL
    ' \
    --tree-filter '
        # replace .hgignore with .gitignore
        if test -f .hgignore
        then
            sed -e "/syntax: glob/,+1d" .hgignore > .gitignore
            rm .hgignore
        fi
    ' \
    --msg-filter '
        # replace tabs with spaces in commit messages
        expand
    ' \
    --commit-filter '
        if test \( "$GIT_COMMIT" = `git rev-parse v7.2.434~6` \) \
             -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~5` \) \
             -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~4` \) \
             -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~3` \) \
             -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~2` \) \
             -o \( "$GIT_COMMIT" = `git rev-parse v7.2.434~1` \)
        then
            # remove 6 commits from the 7.2 branch, only meant for 7.3
            #   from "First step in the Vim 7.3 branch."
            #   till "Undo changes that are meant for the Vim 7.3 branch."
            skip_commit "$@"
        else
            # remove empty commits, most from handling of tags and branches
            git_commit_non_empty_tree "$@"
        fi
    ' \
    -- --all
