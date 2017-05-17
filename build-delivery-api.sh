#!/usr/bin/env bash

RELEASE_VERSION=$1
DELIVERY_QUALIFIER=$2
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$RELEASE_VERSION" ]; then
        echo "ERROR: Release version argument not supplied"
        exit 1
fi
if [ -z "$DELIVERY_QUALIFIER" ]; then
        echo "ERROR: Delivery qualifier not supplied, use '-' if you don't want a delivery"
        exit 1
fi

pushd ${WORKSPACE}

# build the delivery if a delivery version is provided
if [ "$DELIVERY_QUALIFIER" != "-" ]; then
	mkdir -p target/delivery
	pushd target/delivery
	NAME="bean_validation-${RELEASE_VERSION//./_}-${DELIVERY_QUALIFIER}-artifacts"
	mkdir -p ${NAME}
	cp -a ../validation-api-${RELEASE_VERSION}.jar ${NAME}/
	cp -a ../validation-api-${RELEASE_VERSION}-javadoc.jar ${NAME}/
	cp -a ../validation-api-${RELEASE_VERSION}-sources.jar ${NAME}/
	zip -r ${NAME}.zip ${NAME}
	popd
fi

popd
