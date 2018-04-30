#!/usr/bin/env bash

# See utils.sh
source $(readlink -f ${BASH_SOURCE[0]} | xargs dirname)/utils.sh

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

# Storing the script in a file is necessary to be able to execute the sftp command in "try_multiple_times"
CREATE_DIR_SFTP_SCRIPT=$(mktemp)
cat >$CREATE_DIR_SFTP_SCRIPT <<EOF
mkdir $DIST_PARENT_DIR/$RELEASE_VERSION
quit
EOF
try_multiple_times sftp -b $CREATE_DIR_SFTP_SCRIPT frs.sourceforge.net || echo "Directory already exists. Skipping creation."
rm $CREATE_DIR_SFTP_SCRIPT

try_multiple_times scp -v README.md frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/
try_multiple_times scp -v changelog.txt frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/
try_multiple_times scp -v distribution/target/$PROJECT-dist-$RELEASE_VERSION.zip frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/
try_multiple_times scp -v distribution/target/$PROJECT-dist-$RELEASE_VERSION.tar.gz frs.sourceforge.net:$DIST_PARENT_DIR/$RELEASE_VERSION/

popd

echo "Distribution uploaded to SourceForge"
