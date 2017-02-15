#!/usr/bin/env bash

PROJECT=$1
RELEASE_VERSION=$2
DIST_PARENT_DIR=${3:-"/home/frs/project/hibernate/$PROJECT"}
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
fi

echo "#####################################################"
echo "# Uploading $PROJECT $RELEASE_VERSION on"
echo "# SourceForge: $DIST_PARENT_DIR"
echo "#####################################################"
echo "Workspace: $WORKSPACE"

pushd $WORKSPACE

((echo mkdir $DIST_PARENT_DIR/$RELEASE_VERSION; echo quit) | sftp -b - frs.sourceforge.net) || echo "Directory already exists. Skipping creation."
scp README.md frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/
scp changelog.txt frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/
scp distribution/target/$PROJECT-dist-$RELEASE_VERSION.zip frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/
scp distribution/target/$PROJECT-dist-$RELEASE_VERSION.tar.gz frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/

popd

echo "Distribution uploaded to SourceForge"
