#!/usr/bin/env bash
set -euxo pipefail
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#
# Clean up prior artefacts
#
rm -f ${SCRIPTPATH}/tmp/*.json

#
# Determine the platform to find correct jq binary to use
#
if [ "$(uname)" == "Darwin" ]; then
    jqBinary="${SCRIPTPATH}/bin/jq-osx-amd64"
    valeBinary="vale"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    jqBinary="${SCRIPTPATH}/bin/jq-linux64"
    wget https://github.com/errata-ai/vale/releases/download/v2.15.4/vale_2.15.4_Linux_64-bit.tar.gz
    tar -xvzf vale_2.15.4_Linux_64-bit.tar.gz -C "${SCRIPTPATH}/bin"
    valeBinary="${SCRIPTPATH}/bin/vale"
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
${valeBinary} --output=JSON "${SCRIPTPATH}/good" > "${SCRIPTPATH}/tmp/good.json"

#
# Use https://stedolan.github.io/jq/manual/#length to count encountered errors
# We expect 0 because all examples in the good folder should pass
#
expectedErrorCount=0
hits=$(cat ${SCRIPTPATH}/tmp/good.json | ${jqBinary} '. | length')
if [ "$hits" == "$expectedErrorCount" ] ;then
    echo "All good examples passed!"
    passedGood=0
else
    echo "Error when running 'good' test scenarios:"
    echo "Unexpected result count. Should be ${expectedErrorCount} but found ${hits}."
    cat ${SCRIPTPATH}/tmp/good.json
    passedGood=1
fi

#
# Run vale for `bad` folder and store output
#
${valeBinary} --output=JSON "${SCRIPTPATH}/bad" > "${SCRIPTPATH}/tmp/bad.json"

#
# Use https://stedolan.github.io/jq/manual/#length to count encountered errors
# We expect them to be equal the number of files in the directory
# We need to add 0 to the count result in order to 'typecast' it into an integer
#
expectedErrorCount=$(find ${SCRIPTPATH}/bad -type f -name '*.md' | wc -l)
expectedErrorCount="$(($expectedErrorCount + 0))"
hits=$(cat ${SCRIPTPATH}/tmp/bad.json | ${jqBinary} '. | length')
if [ "$hits" == "$expectedErrorCount" ] ;then
    echo "Bad result count is as expected"
    passedBad=0
else
    echo "Error when running 'bad' test scenarios:"
    echo "Unexpected result count. Should be ${expectedErrorCount} but found ${hits}."
    cat ${SCRIPTPATH}/tmp/bad.json
    passedBad=1
fi

#
# Will let this exit with a non zero exit code if either case above hit errors
#
exit $((passedBad+passedGood))
