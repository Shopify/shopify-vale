content=$(vale --output=JSON good)
if [ "$content" == "{}" ] ;then
    echo "All good examples passed!"
    passedGood=0
else
    echo "Unexpected results from good examples:"
    echo $content
    passedGood=1
fi

## Use https://stedolan.github.io/jq/manual/#TypesandValues to validate ?

vale --output=JSON bad > './tmp/bad.json'
#echo ./bin/jq-osx-amd64 -f './tmp/bad.json' | length

hits=$(cat ./tmp/bad.json | ./bin/jq-osx-amd64 '. | length')

if [ $hits == 1 ] ;then
    echo "Bad result count is as expected"
    passedBad=0
else
    echo "Unexpected bad result count:"
    cat ./tmp/bad.json
    passedBad=1
fi

# Will let this exit with a non zero exit code if either case above hit errors
exit $((passedBad+passedBad))
