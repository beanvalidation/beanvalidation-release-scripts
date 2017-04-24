#!/usr/bin/env bash

RELEASE_VERSION=$1
VERSION_FAMILY=$2
RELEASE_VERSION_QUALIFIER=$3
NEW_VERSION=$4
BRANCH=$5
PUSH_CHANGES=${6:-false}
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$RELEASE_VERSION" ]; then
        echo "ERROR: Release version argument not supplied"
        exit 1
fi
if [ -z "$VERSION_FAMILY" ]; then
        echo "ERROR: Version family argument not supplied"
        exit 1
fi
if [ -z "$NEW_VERSION" ]; then
        echo "ERROR: New version argument not supplied"
        exit 1
fi
if [ -z "$BRANCH" ]; then
        echo "ERROR: Branch argument not supplied"
        exit 1
fi

pushd ${WORKSPACE}

# Update the versions in the build.xml file
sed -i 's@<property name="bv\.version" value=".*" />@<property name="bv.version" value="'${RELEASE_VERSION}'" />@' build.xml
if [ ! -z "$RELEASE_VERSION_QUALIFIER" ]; then
	# there is an issue with this specific expression if passed directly to sed
	sed_expression='s@<property name="bv\.version\.qualifier" value=".*" />@<property name="bv.version.qualifier" value=" ('${RELEASE_VERSION_QUALIFIER}')" />@'
	sed -i "${sed_expression}" build.xml
fi
sed -i 's@<property name="bv\.revdate" value=".*" />@<property name="bv.revdate" value="'$(date +%Y-%m-%d)'" />@' build.xml

git add build.xml
git commit -m "[Jenkins release job] Preparing release $RELEASE_VERSION"
git tag $RELEASE_VERSION

# Generate the specification
ant all.doc

# Clone the website and push the generated specification to the website
git clone git@github.com:beanvalidation/beanvalidation.org.git
pushd beanvalidation.org
git checkout production
SPEC_DIR=${VERSION_FAMILY}/spec
VERSION_DIR=${SPEC_DIR}/${RELEASE_VERSION,,}
mkdir -p ${VERSION_DIR}
cp -f ../target/html/index.html ${SPEC_DIR}/
cp -f ../target/html/index.html ${VERSION_DIR}/
cp -f ../target/pdf/index.pdf ${SPEC_DIR}/bean-validation-specification.pdf
cp -f ../target/pdf/index.pdf ${VERSION_DIR}/bean-validation-specification.pdf
git add ${SPEC_DIR}
git commit -m "[Jenkins release job] Release specification $RELEASE_VERSION"
popd

# Go back to a snapshot version
sed -i 's@<property name="bv\.version" value=".*" />@<property name="bv.version" value="'${NEW_VERSION}'" />@' build.xml
sed -i 's@<property name="bv\.version\.qualifier" value=".*" />@<property name="bv.version.qualifier" value="" />@' build.xml
sed -i 's@<property name="bv\.revdate" value=".*" />@<property name="bv.revdate" value="${current.date}" />@' build.xml

# Prepare next development iteration
git add build.xml
git commit -m "[Jenkins release job] Preparing next development iteration"

# Push the changes if required
if [ "$PUSH_CHANGES" = true ] ; then
	echo "Pushing changes to the upstream repository."
	git push origin $BRANCH
	git push origin $RELEASE_VERSION

	echo "Pushing changes to the upstream beanvalidation.org repository."
	pushd beanvalidation.org
		git push origin production
	popd
else
	echo "WARNING: Not pushing changes to the upstream repository."
fi

popd
