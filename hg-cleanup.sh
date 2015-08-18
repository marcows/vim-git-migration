#!/bin/bash

# Vim HG repository cleanup
#
# Overview:
# - close stale branches
# - fix wrong tags
# - remove unused tags
# - add missing tags
# - rename tags: replace - by .

set -e

hg config extensions.rebase || { echo -e "Rebase extension has to be enabled in ~/.hgrc:\n[extensions]\nrebase =" && exit 1; }

# close stale branches, switch back to default branch afterwards
# This has the slightly bad visual side-effect of parallel development from the
# previous branch head up to the corresponding closing commit in "hg log
# --graph", but is the correct thing to do to avoid seemingly active branches
# showing up in "hg branches" output.
hg update -C vim
hg commit --close-branch -m"Close invalid branch 'vim'"
hg update -C vim72
hg commit --close-branch -m"Close unused branch 'vim72'"
hg update -C vim73
hg commit --close-branch -m"Close old branch 'vim73'"
hg update -C default

# remove unused branch lines
# However, since the network protocol works append-only, you cannot push it
# to the public repo. This would have to be done directly on the server via SSH
# or an admin interface.
# And still this change would have no effect when pulling from existing
# clones, it would have to be stripped there as well, so ignore this step.
#hg strip vim
#hg strip vim72

# find potentially wrong tags by checking whether the patch number had been
# added to src/version.c in that changeset
#for i in $(hg tags | grep -o "v7-.*-[^ ]*"); do hg diff -c $i src/version.c | grep -q "^+    $(echo $i | sed -e 's/v7-.*-0*//')," || echo $i; done
# result:
# v7-4-415
# v7-4b-000
# v7-3-523
# v7-3-143
# v7-2-446
# v7-2-443
# v7-2-442
# v7-2-441
# v7-2-440
# v7-2-439
# v7-2-438
# v7-2-437
# v7-2-436
# v7-2-232
# v7-2-176
# v7-2-167fix
# v7-2-168
# v7-2-082
# v7-2-080
# v7-2-000
# v7-2c-000
# v7-2b-000
# v7-2a-00
# v7-1-258
# v7-1-008
# v7-0-225

# determine the actually wrong tags after manual inspection
# v7-4-415
# v7-3-143
# v7-2-446
# v7-2-443
# v7-2-442
# v7-2-441
# v7-2-440
# v7-2-439
# v7-2-438
# v7-2-437
# v7-2-436
# v7-2-232
# v7-2-176
# v7-2-167fix
# v7-2-168
# v7-2-082
# v7-2-080
# v7-1-008
# v7-0-225

# fix the wrong tags
# Do not edit the .hgtags file manually, but rely on "hg tag" to do the right
# thing, see
#   http://mercurial.selenic.com/wiki/Tag
#   http://mercurial.selenic.com/wiki/TagDesign
hg tag -f --local rebasedest
hg tag -f -r 2ec8266fa254f9f90fd302df275d2813ae08a8e6 v7-0-225
hg tag -f -r 042fa969dab175d414d611425d8a61424bacf75f v7-1-008
hg tag -f -r 12cecc379574aba2231cbba54c4eaeef3432db69 v7-2-080
hg tag -f -r be7491f23e9d8818821de61d9ce53cb1cb1c7dc9 v7-2-082
hg tag -f -r ad41c6afaa7b0b512cd97dd07a93cc0504508227 v7-2-168
hg tag -f -r e8eeeff19eae568f4642cb9f368a1aec6c749a61 v7-2-176
hg tag -f -r 5bd06a91c65c06847fb0d618c71736d7c73e95d2 v7-2-232
hg tag -f -r e12b9d992389cc770eb72e16932313cd0905190f v7-2-436
hg tag -f -r ecb9c2b70b0f6e9918e75bf4e1ac887748a2313a v7-2-437
hg tag -f -r d44112feb8153ffaa6ab8ec6442c5c4af0951728 v7-2-438
hg tag -f -r ea7c2d89b76bf42eb0da3459e8813104d76bca02 v7-2-439
hg tag -f -r cd6e6876308e4e0fb621431646ebeec4b49a2504 v7-2-440
hg tag -f -r f838615313cd5832efa624526a7575668fb40da9 v7-2-441
hg tag -f -r b0ebf9d121ff99eb2e1697a35dca528e7ecb8f4c v7-2-442
hg tag -f -r 0c1e413c32f1f3f8e28ebf8a030cedeeb664cd46 v7-2-443
hg tag -f -r b619655b31db9469f6fe41932daff7a566079097 v7-2-446
hg tag -f -r afb476746692322523f167c218803317b87623e3 v7-3-143
hg tag -f -r 353442863d8558dc89d35ef349b60ebb2e38de0e v7-4-415
hg tag -r v7-2-167fix v7-2-167
hg tag --remove v7-2-167fix

# Optionally squash all separate tag changing commits into one
# with a proper description

cat <<EOF > logfile.txt
Fix wrong tags

v7-2-167fix has been renamed to v7-2-167 because the state in repository
matched version 7.2.167.

The others have been moved to the correct changeset.
EOF

hg rebase --dest rebasedest --source tip~19 --collapse --logfile logfile.txt
rm logfile.txt

# remove unused tag
hg tag -m"Remove unused tag from invalid line of history" --remove start

# add missing tags
hg tag -f --local rebasedest
hg tag -r f03c3fae0a99 v7-0-076
hg tag -r v7-2-000 v7-2
hg tag -r ee53a39d5896 v7-3
hg tag -r f0915ae869cf v7-3-001
hg tag -r 2e72d84e8965 v7-3-139
hg tag -r 96a7b564c2f3 v7-3-140
hg tag -r 0d201adaf9c5 v7-3-141
# The following tags could not be created because the changeset is combined
# with the changeset of the subsequent patch: v7-1-083 v7-2-054

# Optionally squash all separate tag adding commits into one
# with a proper description
hg rebase --dest rebasedest --source tip~6 --collapse -m"Add missing tags"

## rename tags: replace - by .
#hg tag -f --local rebasedest
#echo "Renaming all tags, took about 1 second per tag for me (63 minutes) + additional 41 minutes for rebasing ..."
#for i in `hg tags | tac | awk '/^v7-/ {print $1}'`; do hg tag -r $i ${i//-/.} && hg tag --remove $i; done
#
## Optionally squash all separate tag changing commits into one
## with a proper description
#hg rebase --dest rebasedest --source "children(rebasedest)" --collapse -m"Rename tags to match the normal version notation"

# rename tags: replace - by .
# For speed purposes do it manually instead of using "hg tag", but keep identical output
for i in `hg tags --debug | tac | awk '/^v7-/ {print $1 ":" $2}'`; do
    # input example: $i=v7-4-119:5541:2f99966971b0556bc302ec809712f5ba3f030028
    REV=${i/*:/}
    OLDTAG=${i/:*/}
    NEWTAG=${OLDTAG//-/.}
    echo -e "$REV $NEWTAG\n$REV $OLDTAG\n0000000000000000000000000000000000000000 $OLDTAG" >> .hgtags
done
hg commit -m"Rename tags to match the normal version notation"

# cleanup
hg tag --local --remove rebasedest

echo "HG repo cleanup finished"
