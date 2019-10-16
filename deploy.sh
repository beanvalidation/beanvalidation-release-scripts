#!/usr/bin/env bash

PROJECT=$1
WORKSPACE=${WORKSPACE:-'.'}

pushd ${WORKSPACE}

if [ -z "$PROJECT" ]; then
       echo "ERROR: Project not supplied"
       exit 1
fi

mvn -Prelease,documentation-pdf clean deploy -s $HOME/.m2/settings-search-release.xml -DskipTests=true -Dcheckstyle.skip=true -DperformRelease=true -Dmaven.compiler.useIncrementalCompilation=false -DaltReleaseDeploymentRepository="jboss-releases-repository::https://repository.jboss.org/nexus/service/local/staging/deploy/maven2/"

popd
