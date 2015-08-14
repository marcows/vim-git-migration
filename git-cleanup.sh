#!/bin/sh

# Vim Git repository cleanup

##############
#  - git-filter-branch und git-rebase machen tags kaputt
#    so klappt es: git filter-branch -f --tree-filter 'rm -f .hgignore' HEAD~5.. --tags
#    -> user müssen git fetch --tags machen, damit geänderter Tag aktualisiert wird -> ach komm, einfach neuer Klon mit --reference ../vim-git-test1 --dissociate
##############

# siehe meine erste Mail vom April für mehrere Punkte

# replace .hgignore with .gitignore

# falsche commits "First step 7.3" bis "Undo changes meant for 7.3" im 7.2 branch könnten eliminiert werden

