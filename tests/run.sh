#!/usr/bin/env bash

#
# Determine the platform to find correct jq binary to use
#
if [ "$(uname)" == "Darwin" ]; then
    jqBinary="./bin/jq-osx-amd64"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    jqBinary="./bin/jq-linux64"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    echo "Win32 is not supported"
    exit 1
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    echo "Win64 is not supported"
    exit 1
fi

#
# Run vale for `good` folder and store output
#
vale --output=JSON good > './tmp/good.json'

#
# Use https://stedolan.github.io/jq/manual/#length to count encountered errors
# We expect 0 because all examples in the good folder should pass
#
expectedErrorCount=0
hits=$(cat ./tmp/good.json | ${jqBinary} '. | length')
if [ $hits == $expectedErrorCount ] ;then
    echo "All good examples passed!"
    passedGood=0
else
    echo "Error when running 'good' test scenarios:"
    echo "Unexpected result count. Should be ${expectedErrorCount} but found ${hits}."
    cat ./tmp/good.json
    passedGood=1
fi

#
# Run vale for `bad` folder and store output
#
vale --output=JSON bad > './tmp/bad.json'

#
# Use https://stedolan.github.io/jq/manual/#length to count encountered errors
# We expect 1 because all bad examples are intentionally added here
#
expectedErrorCount=$(find bad -type f -name '*.md' | wc -l)
hits=$(cat ./tmp/bad.json | ${jqBinary} '. | length')
if [ $hits == $expectedErrorCount ] ;then
    echo "Bad result count is as expected"
    passedBad=0
else
    echo "Error when running 'bad' test scenarios:"
    echo "Unexpected result count. Should be ${expectedErrorCount} but found ${hits}."
    cat ./tmp/bad.json
    passedBad=1
fi

#
# Will let this exit with a non zero exit code if either case above hit errors
#
exit $((passedBad+passedBad))
