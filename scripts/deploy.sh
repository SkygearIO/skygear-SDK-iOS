#!/bin/bash -e

# Update docs.skygear.io

if [ -n "$TRAVIS_TAG" ]; then
    if [ "$TRAVIS_TAG" == "latest" ]; then
        make doc-deploy VERSION=latest GIT_REF_NAME=latest
    else
        make doc-deploy VERSION="v$TRAVIS_TAG" GIT_REF_NAME="$TRAVIS_TAG"
    fi
else
    make doc-deploy VERSION="${TRAVIS_BRANCH/master/canary}" GIT_REF_NAME="$TRAVIS_BRANCH"
fi
