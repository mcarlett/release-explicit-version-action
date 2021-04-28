#!/bin/bash

# Exit whenever a command fails
set -e

TAG=v$RELEASE_VERSION
echo "Checkout $DEV_BRANCH"
git checkout $DEV_BRANCH
echo "Pull upstream"
git pull upstream $DEV_BRANCH
echo "Prepare release with version $RELEASE_VERSION and set development version $DEVEL_VERSION"
mvn -B release:prepare -DreleaseVersion=$RELEASE_VERSION -DdevelopmentVersion=$DEVEL_VERSION
echo "Perform release"
mvn release:perform
echo "Rebase branch $RELEASE_BRANCH"
git checkout $RELEASE_BRANCH
git pull upstream $RELEASE_BRANCH
git rebase $TAG
echo "Create release tag $TAG"
git push upstream $DEV_BRANCH $RELEASE_BRANCH $TAG
echo "::set-output name=generated-tag::$(echo $TAG)"
echo "Done!"
