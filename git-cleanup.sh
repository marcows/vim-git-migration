#!/bin/sh

# Vim Git repository cleanup

set -e

# remove invalid, unused and old branches
git branch -D vim vim72 vim73

# find empty commits
#for sha in $(git rev-list --min-parents=1 --max-parents=1 --all) ; do if [ $(git rev-parse ${sha}^{tree}) == $(git rev-parse ${sha}^1^{tree} ) ]; then echo $sha; fi; done > empty-commits.txt
# manually check if the empty commits can be removed
#git show $(<empty-commits.txt) --oneline --decorate | vim -
# -> one commit with message "Remove tag." is referenced by tag v7-3-143
#    what does filter-branch do in this case?
#    -> better fix in HG repo

# remove empty commits, mostly the .hgtags commits

# remove 6 commits from the 7.2 branch, only meant for 7.3
#   from "First step in the Vim 7.3 branch."
#   till "Undo changes that are meant for the Vim 7.3 branch."
# -> kein Tag dran, wäre also möglich -> erst noch diff vgl. mit richtigen commits auf 7.3 branch

##############
#  - git-filter-branch und git-rebase machen tags kaputt
#    so klappt es: git filter-branch -f --tree-filter 'rm -f .hgignore' HEAD~5.. --tags
#    -> user müssen git fetch --tags machen, damit geänderter Tag aktualisiert wird -> ach komm, einfach neuer Klon mit --reference ../vim-git-test1 --dissociate
##############

# siehe meine erste Mail vom April für mehrere Punkte

# replace .hgignore with .gitignore
