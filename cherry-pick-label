#!/bin/bash

#Checkouting a new brach called intermed based on an existent branch called "test-prod".
git checkout -b "intermed" origin/teste-prod

#Return last 10 (could be other number you want or all) PR have been closed and with a label "teamx".
gh pr list -l teamx -s closed --json number | jq '.[0,1,2,3,4,5,6,7,8,9] | .number' | grep [0-9] > prs

file="prs"
lines=$(cat $file)
#If file "com" exists, delete it.
[ -e com ] && rm com
touch com
for line in $lines
do
  #Writing all commits from PRs above.
  gh api -H "Accept: application/vnd.github.v3+json" /repos/$youraccount/$yourepo/pulls/$line/commits | jq '.[] | .sha' | sed -e 's/\"//g' >> com
done

#Do the cherry-pick of commits maped above.
file="com"
lines=$(cat $file)
set +e
for line in $lines
do
  git cherry-pick $line
done
set -e

#Delete unused files
rm prs com

#Do the push
git push -u origin intermed

#Create a PR for a destin branch called "test-pre-prod" witch a label "auto".
gh pr create --base test-pre-prod  --title "a title" --body "a body" -l auto

#You could want delete the branch "intermed" here.
#[...]
