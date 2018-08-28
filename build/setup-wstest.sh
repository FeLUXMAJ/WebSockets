#!/usr/bin/env bash

if [ "$TRAVIS_OS_NAME" == "osx" ]; then
    # Install python
    brew update > /dev/null
    brew install python
fi

PYTHON_CMD=python
if type -p python2.7 > /dev/null; then
    echo "Using 'python2.7' executable because it's available."
    PYTHON_CMD=python2.7
fi

$PYTHON_CMD --version

# Install local virtualenv
mkdir .python
cd .python
curl -OL https://pypi.python.org/packages/d4/0c/9840c08189e030873387a73b90ada981885010dd9aea134d6de30cd24cb8/virtualenv-15.1.0.tar.gz

# Validate checksum
expected=02f8102c2436bb03b3ee6dede1919d1dac8a427541652e5ec95171ec8adbc93a
actual=$(sha256sum -b virtualenv-15.1.0.tar.gz | cut -d' ' -f1)
if [ "$expected" != "$actual" ]; then
    echo "The checksum for the virtualenv package does not match the expected value." 1>&2
    echo "This can often happen if the download site is down. Try restarting the build." 1>&2
    exit 1
fi

tar xf virtualenv-15.1.0.tar.gz
cd ..

# Make a virtualenv
$PYTHON_CMD ./.python/virtualenv-15.1.0/virtualenv.py .virtualenv

.virtualenv/bin/python --version
.virtualenv/bin/pip --version

# Install autobahn into the virtualenv
.virtualenv/bin/pip install autobahntestsuite

# We're done. The travis config has already established the path to WSTest should be within the virtualenv.
ls -l .virtualenv/bin
.virtualenv/bin/wstest --version