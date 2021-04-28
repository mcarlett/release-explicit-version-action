#!/bin/bash

# Exit whenever a command fails
set -e

TAG=v$RELEASE_VERSION

env

echo "Fetch remote"
git fetch
echo "Checkout $DEVEL_BRANCH"
git checkout $DEVEL_BRANCH
echo "Pull"
git pull origin $DEVEL_BRANCH
echo "Prepare release with version $RELEASE_VERSION and set development version $DEVEL_VERSION"
mvn -B release:prepare -DreleaseVersion=$RELEASE_VERSION -DdevelopmentVersion=$DEVEL_VERSION
echo "Set user config"
git config user.email $GITHUB_ACTOR@workflow.github.com
git config user.name $GITHUB_ACTOR
echo "Perform release"
mvn release:perform
echo "Rebase branch $RELEASE_BRANCH"
git checkout $RELEASE_BRANCH
git pull $RELEASE_BRANCH
git rebase $TAG
echo "Create release tag $TAG"
git push $DEVEL_BRANCH $RELEASE_BRANCH $TAG
echo "::set-output name=generated-tag::$(echo $TAG)"
echo "Done!"
