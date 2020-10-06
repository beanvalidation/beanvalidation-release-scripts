#!/usr/bin/env bash

PROJECT=$1
RELEASE_VERSION=$2
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
else
	echo "Setting version to '$RELEASE_VERSION'";
fi

echo "Preparing the release ..."

pushd $WORKSPACE/beanvalidation-release-scripts
bundle install
popd

pushd $WORKSPACE
git checkout ${RELEASE_VERSION}

if [ "$PROJECT" != "beanvalidation-tck" ]; then
	./beanvalidation-release-scripts/pre-release.rb -p $PROJECT -v $RELEASE_VERSION
fi
bash beanvalidation-release-scripts/validate-release.sh $PROJECT $RELEASE_VERSION

popd

echo "Release ready: version is updated to $RELEASE_VERSION"
