#!/bin/bash

# review.sh
# This script reads 3 positional parameters and prints them out.

POSPAR1="$1"
branch=$1
if [ "$branch" == "" ]
	then echo "please give the branch name"
	exit
fi

echo "-- Pushing your changes --"
git push origin $branch

echo "-- Merging into staging (after pull updates) --"
git checkout staging
git pull origin staging
git merge $branch

echo "-- Pushing to staging --"
git push origin staging

echo "-- Deploying the staging --"
bundle exec cap staging deploy

# Changing to master branch
git checkout master

echo "*** PLEASE DON'T FORGET TO CHANGE PLAN.IO STATUS TO FEEDBACK ***"