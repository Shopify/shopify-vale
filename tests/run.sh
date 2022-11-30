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
${valeBinary} --config "${SCRIPTPATH}/.vale.ini" --output=JSON "${SCRIPTPATH}/pass" > "${SCRIPTPATH}/tmp/pass.json"

#
# Use https://stedolan.github.io/jq/manual/#length to count encountered errors
# We expect 0 because all examples in the good folder should pass
#
expectedErrorCount=0
hits=$(cat ${SCRIPTPATH}/tmp/pass.json | ${jqBinary} '. | length')
if [ "$hits" == "$expectedErrorCount" ] ;then
    echo "All 'pass' test scenarios passed!"
    errorsInPass=0
else
    echo "Error when running 'pass' test scenarios:"
    echo "Unexpected result count. Should be ${expectedErrorCount} but found ${hits}."
    cat ${SCRIPTPATH}/tmp/pass.json
    errorsInPass=1
fi

#
# Run vale for `bad` folder and store output
#
${valeBinary} --config "${SCRIPTPATH}/.vale.ini" --output=JSON "${SCRIPTPATH}/fail" > "${SCRIPTPATH}/tmp/fail.json"

#
# Use https://stedolan.github.io/jq/manual/#length to count encountered errors
# We expect them to be equal the number of files in the directory
# We need to add 0 to the count result in order to 'typecast' it into an integer
#
expectedErrorCount=$(find ${SCRIPTPATH}/fail -type f -name '*.md' | wc -l)
expectedErrorCount="$(($expectedErrorCount + 0))"
hits=$(cat ${SCRIPTPATH}/tmp/fail.json | ${jqBinary} '. | length')
if [ "$hits" == "$expectedErrorCount" ] ;then
    echo "Fail result count is as expected"
    errorsInFail=0
else
    echo "Error when running 'fail' test scenarios:"
    echo "Unexpected result count. Should be ${expectedErrorCount} but found ${hits}."
    cat ${SCRIPTPATH}/tmp/fail.json
    errorsInFail=1
fi

#
# Will let this exit with a non zero exit code if either case above hit errors
#
exit $((errorsInPass+errorsInFail))
