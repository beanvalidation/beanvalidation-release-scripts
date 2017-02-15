#!/usr/bin/env bash

PROJECT=$1
RELEASE_VERSION=$2
VERSION_FAMILY=$3
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
fi
if [ -z "$VERSION_FAMILY" ]; then
	echo "ERROR: Version family argument not supplied"
	exit 1
fi

pushd ${WORKSPACE}

if [ $PROJECT == "beanvalidation-api" ]; then
	rsync -rzh --progress --delete --protocol=28 target/apidocs/ filemgmt.jboss.org:/docs_htdocs/hibernate/beanvalidation/spec/$VERSION_FAMILY/api
	STABLE_LINK_NAME=api
	STABLE_LINK_TARGET="../../beanvalidation/spec/$VERSION_FAMILY/api"
elif [ $PROJECT == "beanvalidation-tck" ]; then
	unzip distribution/target/$PROJECT-dist-$RELEASE_VERSION.zip -d distribution/target/unpacked
	rsync -rzh --progress --delete --protocol=28 distribution/target/unpacked/${PROJECT}-dist-${RELEASE_VERSION}/docs/ filemgmt.jboss.org:/docs_htdocs/hibernate/beanvalidation/tck/$VERSION_FAMILY
	STABLE_LINK_NAME=tck
	STABLE_LINK_TARGET="../../beanvalidation/tck/$VERSION_FAMILY"
fi

# If the release is the new stable one, we need to update the doc server (outdated content descriptor and /stable/ symlink)

function version_gt() {
	test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1";
}

if [[ $RELEASE_VERSION =~ .*\.Final ]]; then
	wget -q http://docs.jboss.org/hibernate/_outdated-content/${PROJECT}.json -O ${PROJECT}.json
	if [ ! -s ${PROJECT}.json ]; then
		echo "Error downloading the ${PROJECT}.json descriptor. Exiting."
		exit 1
	fi
	CURRENT_STABLE_VERSION=$(cat ${PROJECT}.json | jq -r ".stable")

	if [ "$CURRENT_STABLE_VERSION" != "$VERSION_FAMILY" ] && version_gt $VERSION_FAMILY $CURRENT_STABLE_VERSION; then
		cat ${PROJECT}.json | jq ".stable = \"$VERSION_FAMILY\"" > ${PROJECT}-updated.json
		if [ ! -s ${PROJECT}-updated.json ]; then
			echo "Error updating the ${PROJECT}.json descriptor. Exiting."
			exit 1
		fi

		scp ${PROJECT}-updated.json filemgmt.jboss.org:docs_htdocs/hibernate/_outdated-content/${PROJECT}.json
		rm -f ${PROJECT}-updated.json

		# update the symlink of stable to the latest release
		# don't indent the EOF!
		sftp filemgmt.jboss.org -b <<EOF
cd docs_htdocs/hibernate/stable/beanvalidation
rm ${PROJECT}
ln -s ${STABLE_LINK_TARGET} ${STABLE_LINK_NAME}
EOF
	fi
	rm -f ${PROJECT}.json
fi

popd
