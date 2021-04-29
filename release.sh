#!/bin/bash

# Exit whenever a command fails
set -e

TAG=v$RELEASE_VERSION

echo "Set user config"
git config --global user.email "$GITHUB_ACTOR@workflow.github.com"
git config --global user.name "$GITHUB_ACTOR"
echo "Fetch remote"
git fetch
echo "Checkout $RELEASE_BRANCH"
git checkout $RELEASE_BRANCH
echo "Pull $RELEASE_BRANCH"
git pull origin $RELEASE_BRANCH
echo "Checkout $DEVEL_BRANCH"
git checkout $DEVEL_BRANCH
echo "Pull $DEVEL_BRANCH"
git pull origin $DEVEL_BRANCH
echo "Merge $RELEASE_BRANCH into $DEVEL_BRANCH"
git merge $RELEASE_BRANCH -m "Reintegrate master"
echo "Prepare release with version $RELEASE_VERSION and set development version $DEVEL_VERSION"
mvn -B -DskipTests -Darguments="-DskipTests" -DpreparationGoals="clean package" -DlocalCheckout=true -DsignTag=true -Dtag=$TAG release:prepare -DreleaseVersion=$RELEASE_VERSION -DdevelopmentVersion=$DEVEL_VERSION
echo "Perform release"
mvn -DskipTests -Darguments="-DskipTests -Dmaven.deploy.skip=true" release:perform
echo "Checkout branch $RELEASE_BRANCH"
git checkout $RELEASE_BRANCH
echo "Rebase $TAG into $RELEASE_BRANCH"
git rebase $TAG
git push origin $RELEASE_BRANCH $DEVEL_BRANCH --follow-tags
echo "::set-output name=generated-tag::$(echo $TAG)"
echo "Done!"
